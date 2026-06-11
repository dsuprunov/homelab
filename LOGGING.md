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
- Vector writer buffer: `256 MiB`, volume cap: `320 MiB`
- OpenSearch log data budget: about `1 GiB`, volume cap: `3 GiB`

## TODO

- Configure OpenSearch retention / ISM policy to keep logs within the lab budget, for example about `1 GiB` or a fixed time window such as `24h` or `7d`
- Install OpenSearch Dashboards for browsing and searching logs through a UI
- Add saved searches / dashboards for namespace, pod, errors, and Kafka/OpenSearch writer health
- Add log normalization after the raw pipeline is stable, including fields such as `message`, `namespace`, `pod`, `container`, and `level`

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

2) Send a container smoke log

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

3) Verify the smoke log reaches Kafka through Vector

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

Goal: install OpenSearch and prepare the data stream that the Vector writer
will write to.

Data stream name: `logs-homelab-default`.

1) Install OpenSearch

```bash
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm repo update

kubectl create namespace opensearch --dry-run=client -o yaml | kubectl apply -f -

printf 'OpenSearch admin password: '
read -r -s OPENSEARCH_INITIAL_ADMIN_PASSWORD
printf '\n'
export OPENSEARCH_INITIAL_ADMIN_PASSWORD

kubectl -n opensearch create secret generic opensearch-admin \
  --from-literal=OPENSEARCH_INITIAL_ADMIN_PASSWORD="$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  --dry-run=client \
  -o yaml \
  | kubectl apply -f -

cat <<'EOF' >/tmp/opensearch-values.yaml
clusterName: opensearch
nodeGroup: master
masterService: opensearch-cluster-master
singleNode: true
replicas: 1

opensearchJavaOpts: "-Xms512m -Xmx512m"

extraEnvs:
  - name: OPENSEARCH_INITIAL_ADMIN_PASSWORD
    valueFrom:
      secretKeyRef:
        name: opensearch-admin
        key: OPENSEARCH_INITIAL_ADMIN_PASSWORD

persistence:
  enabled: true
  storageClass: longhorn
  size: 3Gi

resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    memory: 2Gi

antiAffinity: soft

sysctlInit:
  enabled: true
EOF

helm upgrade --install opensearch opensearch/opensearch \
  --namespace opensearch \
  --version 3.6.0 \
  --values /tmp/opensearch-values.yaml

kubectl -n opensearch get pods -o wide
kubectl -n opensearch rollout status statefulset/opensearch-master --timeout=10m
kubectl -n opensearch get svc
kubectl -n opensearch get pvc -o wide
kubectl -n opensearch exec opensearch-master-0 -- df -h /usr/share/opensearch/data

kubectl -n opensearch get secret opensearch-admin -o jsonpath='{.data.OPENSEARCH_INITIAL_ADMIN_PASSWORD}' | base64 -d; echo
```

Expected result:
- `opensearch-master-0` is running
- Service `opensearch-cluster-master` exists
- The OpenSearch PVC exists with `3Gi` and storage class `longhorn`
- The OpenSearch data volume has enough free space

2) Verify OpenSearch access

```bash
export OPENSEARCH_NAMESPACE=opensearch
export OPENSEARCH_SERVICE=opensearch-cluster-master

kubectl -n opensearch get pods -o wide
kubectl -n opensearch get svc
kubectl -n opensearch port-forward svc/opensearch-cluster-master 9200:9200

OPENSEARCH_INITIAL_ADMIN_PASSWORD="$(
  kubectl -n opensearch get secret opensearch-admin -o jsonpath='{.data.OPENSEARCH_INITIAL_ADMIN_PASSWORD}' | base64 -d
)"

curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" https://127.0.0.1:9200
curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" https://127.0.0.1:9200/_cluster/health?pretty
```

Expected result:
- OpenSearch responds with cluster information
- Cluster health is `green` or `yellow`

3) Create or update the logging data stream template

```bash
curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  -X PUT "https://127.0.0.1:9200/_index_template/logs-homelab-default-template" \
  -H 'Content-Type: application/json' \
  -d '{
    "index_patterns": ["logs-homelab-default"],
    "data_stream": {},
    "priority": 500,
    "template": {
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0,
        "index.refresh_interval": "10s"
      },
      "mappings": {
        "dynamic": true,
        "properties": {
          "@timestamp": { "type": "date" },
          "timestamp": { "type": "date" },
          "time": { "type": "date" },
          "message": { "type": "text" },
          "log": { "type": "text" },
          "source_type": { "type": "keyword" },
          "stream": { "type": "keyword" },
          "tag": { "type": "keyword" },
          "host": { "type": "keyword" },
          "kubernetes": {
            "properties": {
              "namespace_name": { "type": "keyword" },
              "pod_name": { "type": "keyword" },
              "container_name": { "type": "keyword" },
              "container_image": { "type": "keyword" },
              "container_hash": { "type": "keyword" },
              "docker_id": { "type": "keyword" },
              "host": { "type": "keyword" },
              "pod_id": { "type": "keyword" },
              "pod_ip": { "type": "ip" },
              "labels": { "type": "flat_object" }
            }
          }
        }
      }
    },
    "_meta": {
      "description": "Homelab logging data stream template"
    }
  }'; echo
```

Expected result:
- OpenSearch returns `"acknowledged": true`

4) Create and verify the data stream

```bash
curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  -X PUT "https://127.0.0.1:9200/_data_stream/logs-homelab-default"; echo

curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  "https://127.0.0.1:9200/_data_stream/logs-homelab-default?pretty"; echo
```

Expected result:
- The data stream exists
- The data stream uses `logs-homelab-default-template`
- The timestamp field is `@timestamp`
- The first backing index exists

5) Write and search a smoke document

```bash
OPENSEARCH_SMOKE_ID="opensearch-data-stream-smoke-$(date -u +%Y%m%dT%H%M%SZ)"

curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  -X POST "https://127.0.0.1:9200/logs-homelab-default/_doc?refresh=true" \
  -H 'Content-Type: application/json' \
  -d "{
    \"@timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
    \"message\": \"$OPENSEARCH_SMOKE_ID\",
    \"source_type\": \"manual-smoke\"
  }"

curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  -X GET "https://127.0.0.1:9200/logs-homelab-default/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d "{
    \"size\": 1,
    \"query\": {
      \"match_phrase\": {
        \"message\": \"$OPENSEARCH_SMOKE_ID\"
      }
    },
    \"sort\": [
      { \"@timestamp\": \"desc\" }
    ]
  }"; echo
```

Expected result:
- OpenSearch accepts the smoke document
- Search returns the smoke document from a `.ds-logs-homelab-default-*` backing index

6) Check data stream storage

```bash
curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  "https://127.0.0.1:9200/_data_stream/logs-homelab-default/_stats?pretty"; echo

curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  "https://127.0.0.1:9200/_cat/indices/.ds-logs-homelab-default-*?v&h=index,health,pri,rep,docs.count,store.size" ; echo
```

Expected result:
- Store size is small after the smoke test
- Backing index has `pri=1` and `rep=0`

## Step 5: Install and verify Vector OpenSearch writer

Goal: read normalized JSON events from Kafka and write them to the OpenSearch
data stream.

Vector uses the Elasticsearch sink for OpenSearch. The sink runs in
`data_stream` mode, which writes with the bulk `create` action and uses
`logs-homelab-default` from:

```text
data_stream.type: logs
data_stream.dataset: homelab
data_stream.namespace: default
```

OpenSearch user `svc_vector_opensearch_writer` is a service user only for this
`Kafka -> OpenSearch logs data stream` pipeline. Create separate OpenSearch
users for other Vector writers, projects, or datasets. This writer user is used
only by Vector to write pipeline events. Manual OpenSearch search checks below
use the admin user.

1) Create the OpenSearch writer role, user, and Kubernetes secret

```bash
kubectl -n opensearch port-forward svc/opensearch-cluster-master 9200:9200

export OPENSEARCH_URL=https://127.0.0.1:9200
export VECTOR_OPENSEARCH_WRITER_USERNAME=svc_vector_opensearch_writer
export VECTOR_OPENSEARCH_WRITER_ROLE=vector_opensearch_writer

OPENSEARCH_INITIAL_ADMIN_PASSWORD="$(
  kubectl -n opensearch get secret opensearch-admin \
    -o jsonpath='{.data.OPENSEARCH_INITIAL_ADMIN_PASSWORD}' \
    | base64 -d
)"

VECTOR_OPENSEARCH_WRITER_PASSWORD="$(openssl rand -base64 32)"

curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  -X PUT "$OPENSEARCH_URL/_plugins/_security/api/roles/$VECTOR_OPENSEARCH_WRITER_ROLE" \
  -H 'Content-Type: application/json' \
  -d '{
    "cluster_permissions": [
      "cluster_monitor"
    ],
    "index_permissions": [
      {
        "index_patterns": [
          "logs-homelab-default",
          ".ds-logs-homelab-default-*"
        ],
        "allowed_actions": [
          "index",
          "create_index"
        ]
      }
    ]
  }'; echo

curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  -X PUT "$OPENSEARCH_URL/_plugins/_security/api/internalusers/$VECTOR_OPENSEARCH_WRITER_USERNAME" \
  -H 'Content-Type: application/json' \
  -d "{
    \"password\": \"$VECTOR_OPENSEARCH_WRITER_PASSWORD\",
    \"backend_roles\": [],
    \"attributes\": {
      \"description\": \"Kafka to OpenSearch logs data stream writer\"
    }
  }"; echo

curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  -X PUT "$OPENSEARCH_URL/_plugins/_security/api/rolesmapping/$VECTOR_OPENSEARCH_WRITER_ROLE" \
  -H 'Content-Type: application/json' \
  -d "{
    \"backend_roles\": [],
    \"hosts\": [],
    \"users\": [
      \"$VECTOR_OPENSEARCH_WRITER_USERNAME\"
    ]
  }"; echo

kubectl -n logging create secret generic vector-opensearch-writer-auth \
  --from-literal=OPENSEARCH_USERNAME="$VECTOR_OPENSEARCH_WRITER_USERNAME" \
  --from-literal=OPENSEARCH_PASSWORD="$VECTOR_OPENSEARCH_WRITER_PASSWORD" \
  --dry-run=client \
  -o yaml \
  | kubectl apply -f -
```

Expected result:
- OpenSearch role `vector_opensearch_writer` exists
- OpenSearch user `svc_vector_opensearch_writer` exists
- OpenSearch role mapping `vector_opensearch_writer` maps that user
- Secret `vector-opensearch-writer-auth` exists in namespace `logging`.

2) Install Vector OpenSearch writer

```bash
cat <<'EOF' | kubectl apply -n logging -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: vector-opensearch-writer-config
data:
  vector.yaml: |
    data_dir: /var/lib/vector

    sources:
      kafka:
        type: kafka
        bootstrap_servers: sandbox-kafka-bootstrap.kafka-sandbox.svc:9092
        group_id: vector-opensearch-writer
        topics:
          - logs.homelab.normalized.v1
        auto_offset_reset: latest
        decoding:
          codec: json

    sinks:
      opensearch:
        type: elasticsearch
        inputs:
          - kafka
        endpoints:
          - https://opensearch-cluster-master.opensearch.svc:9200
        api_version: v8
        opensearch_service_type: managed
        mode: data_stream
        data_stream:
          type: logs
          dataset: homelab
          namespace: default
          auto_routing: false
          sync_fields: false
        auth:
          strategy: basic
          user: "${OPENSEARCH_USERNAME}"
          password: "${OPENSEARCH_PASSWORD}"
        tls:
          verify_certificate: false
          verify_hostname: false
        buffer:
          type: disk
          max_size: 268435488  # 256 MiB + 32 bytes
          when_full: block
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vector-opensearch-writer
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: vector-opensearch-writer
  template:
    metadata:
      labels:
        app.kubernetes.io/name: vector-opensearch-writer
    spec:
      containers:
        - name: vector
          image: timberio/vector:0.56.0-debian
          args:
            - --config
            - /etc/vector/vector.yaml
          envFrom:
            - secretRef:
                name: vector-opensearch-writer-auth
          volumeMounts:
            - name: config
              mountPath: /etc/vector
              readOnly: true
            - name: data
              mountPath: /var/lib/vector
      volumes:
        - name: config
          configMap:
            name: vector-opensearch-writer-config
        - name: data
          emptyDir:
            sizeLimit: 320Mi  # 256Mi + 64Mi
EOF

kubectl -n logging rollout restart deployment/vector-opensearch-writer

kubectl -n logging rollout status deployment/vector-opensearch-writer --timeout=5m
kubectl -n logging get pods -o wide
kubectl -n logging get deployment vector-opensearch-writer
kubectl -n logging exec deployment/vector-opensearch-writer -- vector validate /etc/vector/vector.yaml
kubectl -n logging logs deployment/vector-opensearch-writer --tail=100
```

Expected result:
- `vector-opensearch-writer` is running
- Vector config is valid
- Logs show the Kafka source and OpenSearch sink without errors

3) Check Kafka consumer lag

```bash
kubectl -n logging run kafka-consumer-groups \
  -i \
  --rm \
  --restart=Never \
  --image=quay.io/strimzi/kafka:1.0.0-kafka-4.2.0 \
  -- bin/kafka-consumer-groups.sh \
    --bootstrap-server sandbox-kafka-bootstrap.kafka-sandbox.svc:9092 \
    --describe \
    --group vector-opensearch-writer
```

Expected result:
- Consumer group `vector-opensearch-writer` exists

4) Verify logs are indexed in OpenSearch

```bash
kubectl -n opensearch port-forward svc/opensearch-cluster-master 9200:9200

OPENSEARCH_INITIAL_ADMIN_PASSWORD="$(
  kubectl -n opensearch get secret opensearch-admin -o jsonpath='{.data.OPENSEARCH_INITIAL_ADMIN_PASSWORD}' | base64 -d
)"

curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  "https://127.0.0.1:9200/_cat/indices/.ds-logs-homelab-default-*?v&h=index,health,docs.count,store.size"

curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  -X GET "https://127.0.0.1:9200/logs-homelab-default/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d '{
    "size": 5,
    "sort": [
      { "@timestamp": "desc" }
    ]
  }'
```

Expected result:
- The backing index is `green`
- `docs.count` is greater than `0`
- The latest documents contain Kubernetes log fields such as `kubernetes`,  `message`, `stream`, `tag`, and `topic`

5) Check OpenSearch storage

```bash
kubectl -n opensearch port-forward svc/opensearch-cluster-master 9200:9200

OPENSEARCH_INITIAL_ADMIN_PASSWORD="$(
  kubectl -n opensearch get secret opensearch-admin -o jsonpath='{.data.OPENSEARCH_INITIAL_ADMIN_PASSWORD}' | base64 -d
)"

curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  "https://127.0.0.1:9200/_data_stream/logs-homelab-default/_stats?pretty"; echo

curl -k -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" \
  "https://127.0.0.1:9200/_cat/indices/.ds-logs-homelab-default-*?v&h=index,health,pri,rep,docs.count,store.size" ; echo

kubectl -n opensearch exec opensearch-master-0 -- df -h /usr/share/opensearch/data
```

Expected result:
- Data stream remains `green`
- Store size stays within the OpenSearch log data budget
- The OpenSearch data volume still has enough free space

## Operations / maintenance

```bash
kubectl -n kafka-sandbox get kafka sandbox
kubectl -n kafka-sandbox get kafkatopic logs.homelab.normalized.v1
kubectl exec -ti -n kafka-sandbox sandbox-dual-role-0 -- sh -c 'df -h /var/lib/kafka/data-0'

kubectl -n logging get pods -o wide
kubectl -n logging get daemonset fluent-bit
kubectl -n logging get deployment vector-normalizer
kubectl -n logging get deployment vector-opensearch-writer
kubectl -n logging logs daemonset/fluent-bit --tail=100
kubectl -n logging logs deployment/vector-normalizer --tail=100
kubectl -n logging logs deployment/vector-opensearch-writer --tail=100

kubectl -n opensearch get statefulset opensearch-master
kubectl -n opensearch get pods -o wide
kubectl -n opensearch get pvc -o wide
kubectl -n opensearch exec opensearch-master-0 -- df -h /usr/share/opensearch/data

kubectl -n logging run kafka-consumer-groups \
  -i \
  --rm \
  --restart=Never \
  --image=quay.io/strimzi/kafka:1.0.0-kafka-4.2.0 \
  -- bin/kafka-consumer-groups.sh \
    --bootstrap-server sandbox-kafka-bootstrap.kafka-sandbox.svc:9092 \
    --describe \
    --group vector-opensearch-writer
```
