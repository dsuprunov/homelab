# Logging

## Goal

```text
Fluent Bit -> Vector normalizer -> Kafka -> Vector OpenSearch writer -> OpenSearch
```

## Architecture

- Fluent Bit runs as a Kubernetes DaemonSet and collects container logs from
  each node.
- Vector normalizer receives logs from Fluent Bit and writes normalized events
  to Kafka.
- Kafka is the durable buffer between normalization and OpenSearch writes.
- Vector OpenSearch writer reads from Kafka and writes to OpenSearch.
- OpenSearch stores logs in the `logs-homelab-default` data stream.

## Limits and retention

- Fluent Bit buffer: `256 MiB`
- Vector normalizer buffer: `256 MiB`
- Kafka topic retention: `24h` and `256 MiB`
- Kafka partitions: `1`
- Vector OpenSearch writer buffer: `256 MiB`
- OpenSearch logging budget: about `1 GiB`

## Step 1: Install and verify Fluent Bit

Goal: install Fluent Bit as the lightweight node log collector, enable a
filesystem buffer, cap disk usage at `256 MiB`, read container
logs, and verify that a test log file is watched.

Step 1 uses a temporary `null` output. Step 2 replaces it with the Vector
normalizer and verifies downstream delivery.

1) Verify Kubernetes access

```bash
kubectl get nodes
kubectl get storageclass
helm version
```

2) Create the logging namespace

```bash
kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -
```

3) Install Fluent Bit

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

    [INPUT]
        Name              tail
        Tag               host.syslog
        Path              /var/log/syslog
        DB                /buffers/flb_syslog.db
        Mem_Buf_Limit     8M
        Skip_Long_Lines   On
        Refresh_Interval  30
        storage.type      filesystem

    [INPUT]
        Name              tail
        Tag               host.messages
        Path              /var/log/messages
        DB                /buffers/flb_messages.db
        Mem_Buf_Limit     8M
        Skip_Long_Lines   On
        Refresh_Interval  30
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
        Name                     null
        Match                    *
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

watch kubectl -n logging get pods -o wide
```

Expected result: one Fluent Bit pod runs on each node.

4) Verify that Fluent Bit starts

```bash
kubectl -n logging get daemonset fluent-bit
kubectl -n logging rollout status daemonset/fluent-bit
kubectl -n logging logs daemonset/fluent-bit --tail=100
```

Expected result: Fluent Bit starts without config errors. Logs show the `tail`
inputs, filesystem storage, and the `null` output.

5) Verify that Fluent Bit watches a test container log

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

kubectl -n logging logs -l app.kubernetes.io/name=fluent-bit --tail=300 --prefix \
  | grep 'fluent-bit-smoke-test'

kubectl delete namespace logging-smoke-test
```

## Step 2: Install and verify Vector normalizer

To be added after Step 1 is accepted.

## Step 3: Install and verify Kafka topic

To be added after Step 2 is accepted.

## Step 4: Install and verify Vector OpenSearch writer

To be added after Step 3 is accepted.

## Step 5: Configure and verify OpenSearch data stream

To be added after Step 4 is accepted.

## Step 6: End-to-end test

To be added after Step 5 is accepted.

## Operations / maintenance

Use these checks while Step 1 is active:

```bash
helm -n logging list

kubectl -n logging get pods -o wide
kubectl -n logging get daemonset fluent-bit
kubectl -n logging logs daemonset/fluent-bit --tail=100
```
