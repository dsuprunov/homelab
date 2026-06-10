# Logging

## Goal

```text
Fluent Bit -> Vector normalizer -> Kafka -> Vector writer -> OpenSearch
```

## Architecture

- Fluent Bit runs as a Kubernetes DaemonSet and collects container logs from each node
- Vector normalizer receives Fluent Forward events from Fluent Bit and writes decoded events to Kafka
- Kafka is the durable buffer between log collection and later processing or OpenSearch writes
- Vector writer reads from Kafka and writes to OpenSearch

## Limits and retention

- Fluent Bit buffer: `256 MiB`, volume cap: `256 MiB`
- Vector normalizer buffer: `256 MiB`, volume cap: `320 MiB`
- Kafka topic `partitions: 1`, `replicas: 1`, retention: `24h` and `256 MiB`
- Vector writer buffer: `256 MiB`
- OpenSearch logging budget: about `1 GiB`

## Step 1: Configure and verify Kafka topic

Goal: create the durable Kafka buffer topic for received logs.

1) Verify Kafka is ready

```bash
kubectl -n kafka-sandbox get kafka sandbox
kubectl -n kafka-sandbox get pods -o wide
kubectl exec -ti -n kafka-sandbox sandbox-dual-role-0 -- sh -c 'df -h /var/lib/kafka/data-0'
```

Expected result:
- `sandbox` is `Ready=True`
- Kafka pods are running
- Kafka data volume has enough free space.

2) Create the logging topic

```bash
cat <<'EOF' | kubectl apply -n kafka-sandbox -f -
apiVersion: kafka.strimzi.io/v1
kind: KafkaTopic
metadata:
  name: logs.homelab.normalized.v1
  labels:
    strimzi.io/cluster: sandbox
spec:
  partitions: 1
  replicas: 1
  config:
    cleanup.policy: delete
    retention.ms: 86400000
    retention.bytes: 268435456
EOF

kubectl -n kafka-sandbox get kafkatopic logs.homelab.normalized.v1
```

Expected result:
- The topic exists with `partitions: 1`, `replicas: 1`.

## Step 2: Install and verify Vector normalizer

Goal: receive Fluent Bit Forward events and write the decoded event to Kafka.

Port `24224` is the Fluent Forward listener.

1) Create or update Vector normalizer

```bash
kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -n logging -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: vector-normalizer-config
data:
  vector.yaml: |
    data_dir: /var/lib/vector

    sources:
      fluent:
        type: fluent
        address: 0.0.0.0:24224
        mode: tcp

    sinks:
      kafka:
        type: kafka
        inputs:
          - fluent
        bootstrap_servers: sandbox-kafka-bootstrap.kafka-sandbox.svc:9092
        topic: logs.homelab.normalized.v1
        encoding:
          codec: json
        buffer:
          type: disk
          max_size: 268435488  # 256 MiB + 32 bytes
          when_full: block
        librdkafka_options:
          client.id: vector-normalizer
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vector-normalizer
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: vector-normalizer
  template:
    metadata:
      labels:
        app.kubernetes.io/name: vector-normalizer
    spec:
      containers:
        - name: vector
          image: timberio/vector:0.56.0-debian
          args:
            - --config
            - /etc/vector/vector.yaml
          ports:
            - name: fluent
              containerPort: 24224
          volumeMounts:
            - name: config
              mountPath: /etc/vector
              readOnly: true
            - name: data
              mountPath: /var/lib/vector
      volumes:
        - name: config
          configMap:
            name: vector-normalizer-config
        - name: data
          emptyDir:
            sizeLimit: 320Mi  # 256Mi + 64Mi
---
apiVersion: v1
kind: Service
metadata:
  name: vector-normalizer
spec:
  selector:
    app.kubernetes.io/name: vector-normalizer
  ports:
    - name: fluent
      port: 24224
      targetPort: fluent
EOF

kubectl -n logging rollout status deployment/vector-normalizer

kubectl -n logging get pods -o wide
kubectl -n logging get svc -o wide

kubectl -n logging exec deployment/vector-normalizer -- vector validate /etc/vector/vector.yaml
kubectl -n logging logs deployment/vector-normalizer --tail=100
```

Expected result:
- `vector-normalizer` is running and exposes port `24224`
- Vector config is valid, the Kafka health check passes
- Logs show the `fluent` source listening on `0.0.0.0:24224`

2) Send a synthetic Forward event to Vector

```bash
kubectl -n logging delete pod vector-normalizer-smoke --ignore-not-found

kubectl -n logging run vector-normalizer-smoke \
  --restart=Never \
  --image=cr.fluentbit.io/fluent/fluent-bit:5.0.7 \
  -- /fluent-bit/bin/fluent-bit \
    -i dummy \
    -p 'Dummy={"log":"vector normalizer smoke test","level":"info","trace_id":"trace-test","span_id":"span-test"}' \
    -p Samples=1 \
    -p Flush_On_Startup=true \
    -o forward \
    -p Host=vector-normalizer.logging.svc \
    -p Port=24224 \
    -p Time_as_Integer=true \
    -m '*'

kubectl -n logging wait --for=condition=Ready pod/vector-normalizer-smoke --timeout=60s

kubectl -n logging logs pod/vector-normalizer-smoke --tail=100
kubectl -n logging delete pod vector-normalizer-smoke --ignore-not-found
```

Expected result:
- Fluent Bit starts without output connection errors.

3) Verify received output in Kafka

```bash
kubectl -n logging run vector-normalizer-consumer \
  -i \
  --rm \
  --restart=Never \
  --image=quay.io/strimzi/kafka:1.0.0-kafka-4.2.0 \
  -- bin/kafka-console-consumer.sh \
    --bootstrap-server sandbox-kafka-bootstrap.kafka-sandbox.svc:9092 \
    --topic logs.homelab.normalized.v1 \
    --from-beginning \
    --timeout-ms 10000
```

Expected result:
- Kafka contains the received JSON event with `vector normalizer smoke test`.

## Step 3: Install and verify Fluent Bit

Goal: install Fluent Bit as the lightweight node log collector and send real
container logs to Vector normalizer.

1) Install Fluent Bit with Vector output

```bash
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

cat <<'EOF' >/tmp/fluent-bit-values.yaml
kind: DaemonSet

image:
  repository: cr.fluentbit.io/fluent/fluent-bit
  tag: "5.0.7"

serviceAccount:
  create: true

rbac:
  create: true
  nodeAccess: true

config:
  service: |
    [SERVICE]
        Flush                     1
        Daemon                    Off
        Log_Level                 info
        Parsers_File              parsers.conf
        HTTP_Server               On
        HTTP_Listen               0.0.0.0
        HTTP_Port                 2020
        storage.path              /buffers
        storage.sync              normal
        storage.checksum          off
        storage.backlog.mem_limit 16M

  inputs: |
    [INPUT]
        Name              tail
        Tag               kube.*
        Path              /var/log/containers/*.log
        Exclude_Path      /var/log/containers/*_logging_*.log
        Parser            cri
        DB                /buffers/flb_kube.db
        Mem_Buf_Limit     16M
        Skip_Long_Lines   On
        Refresh_Interval  10
        storage.type      filesystem

  filters: |
    [FILTER]
        Name                kubernetes
        Match               kube.*
        Kube_URL            https://kubernetes.default.svc:443
        Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
        Kube_Tag_Prefix     kube.var.log.containers.
        Buffer_Size         256k
        Merge_Log           Off
        Keep_Log            On
        K8S-Logging.Parser  Off
        K8S-Logging.Exclude Off

  outputs: |
    [OUTPUT]
        Name                     forward
        Match                    *
        Host                     vector-normalizer.logging.svc
        Port                     24224
        Time_as_Integer          true
        storage.total_limit_size 268435456

extraVolumes:
  - name: fluent-bit-buffer
    emptyDir:
      sizeLimit: 256Mi

extraVolumeMounts:
  - name: fluent-bit-buffer
    mountPath: /buffers
EOF

helm upgrade --install fluent-bit fluent/fluent-bit \
  --namespace logging \
  --version 0.57.6 \
  --values /tmp/fluent-bit-values.yaml

kubectl -n logging rollout status daemonset/fluent-bit

kubectl -n logging get pods
kubectl -n logging get svc
kubectl -n logging get daemonset fluent-bit
kubectl -n logging logs daemonset/fluent-bit --tail=100
```

Expected result:
- One Fluent Bit pod runs on each node and sends logs to `vector-normalizer.logging.svc:24224`

3) Send a container smoke log

```bash
kubectl create namespace logging-smoke-test --dry-run=client -o yaml | kubectl apply -f -

kubectl -n logging-smoke-test run fluent-bit-smoke-test \
  --restart=Never \
  --image=busybox:1.38 \
  -- sh -c 'echo "fluent-bit smoke test $(date -u +%Y-%m-%dT%H:%M:%SZ)"'

kubectl -n logging-smoke-test wait \
  --for=jsonpath='{.status.phase}'=Succeeded \
  pod/fluent-bit-smoke-test \
  --timeout=120s

kubectl -n logging-smoke-test logs fluent-bit-smoke-test

kubectl delete namespace logging-smoke-test
```

4) Verify the smoke log reaches Kafka through Vector

Run the consumer in the `logging` namespace so Fluent Bit does not collect the
consumer output and write it back to Kafka.

```bash
kubectl -n logging run fluent-bit-kafka-consumer \
  -i \
  --rm \
  --restart=Never \
  --image=quay.io/strimzi/kafka:1.0.0-kafka-4.2.0 \
  -- bin/kafka-console-consumer.sh \
    --bootstrap-server sandbox-kafka-bootstrap.kafka-sandbox.svc:9092 \
    --topic logs.homelab.normalized.v1 \
    --from-beginning \
    --timeout-ms 10000 \
  | grep 'fluent-bit smoke test'
```

Expected result:
- Kafka contains the smoke log as a received JSON event.

## Step 4: Configure and verify OpenSearch data stream

To be added after Step 3 is accepted.

## Step 5: Install and verify Vector OpenSearch writer

To be added after Step 4 is accepted.

## Step 6: End-to-end test

To be added after Step 5 is accepted.

## Operations / maintenance

```bash
kubectl -n kafka-sandbox get kafka sandbox
kubectl -n kafka-sandbox get kafkatopic logs.homelab.normalized.v1
kubectl exec -ti -n kafka-sandbox sandbox-dual-role-0 -- sh -c 'df -h /var/lib/kafka/data-0'

kubectl -n logging get pods -o wide
kubectl -n logging get daemonset fluent-bit
kubectl -n logging get deployment vector-normalizer
kubectl -n logging logs daemonset/fluent-bit --tail=100
kubectl -n logging logs deployment/vector-normalizer --tail=100
```
