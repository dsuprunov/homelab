# Kafka Operations

## Install

1) Verify Kubernetes access and Longhorn storage
```bash
kubectl get nodes
kubectl get storageclass
kubectl get storageclass longhorn
```

2) Create Kubernetes namespaces
```bash
kubectl create namespace kafka-sandbox --dry-run=client -o yaml | kubectl apply -f -
```

3) Install Strimzi Cluster Operator
```bash
kubectl create namespace strimzi-system --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install strimzi-cluster-operator \
  oci://quay.io/strimzi-helm/strimzi-kafka-operator \
  --namespace strimzi-system \
  --version 1.0.0 \
  --set 'watchNamespaces={kafka-sandbox}'

watch kubectl -n strimzi-system get pods -o wide

kubectl get crd | grep 'kafka.strimzi.io'
```

4) Create a single-node Kafka cluster in KRaft mode
```bash
cat <<'EOF' | kubectl apply -n kafka-sandbox -f -
apiVersion: kafka.strimzi.io/v1
kind: KafkaNodePool
metadata:
  name: dual-role
  labels:
    strimzi.io/cluster: sandbox
spec:
  replicas: 1
  roles:
    - controller
    - broker
  storage:
    type: jbod
    volumes:
      - id: 0
        type: persistent-claim
        size: 3Gi
        class: longhorn
        deleteClaim: false
        kraftMetadata: shared
---
apiVersion: kafka.strimzi.io/v1
kind: Kafka
metadata:
  name: sandbox
spec:
  kafka:
    version: 4.2.0
    metadataVersion: 4.2-IV1
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
    config:
      offsets.topic.replication.factor: 1
      transaction.state.log.replication.factor: 1
      transaction.state.log.min.isr: 1
      default.replication.factor: 1
      min.insync.replicas: 1
  entityOperator:
    topicOperator: {}
    userOperator: {}
EOF

watch kubectl -n kafka-sandbox get kafka,kafkanodepool,pods,pvc -o wide
```

5) Create a test topic
```bash
cat <<'EOF' | kubectl apply -n kafka-sandbox -f -
apiVersion: kafka.strimzi.io/v1
kind: KafkaTopic
metadata:
  name: kafka-smoke-test
  labels:
    strimzi.io/cluster: sandbox
spec:
  partitions: 1
  replicas: 1
  config:
    cleanup.policy: delete
    retention.ms: 604800000 # 7 days
EOF

kubectl -n kafka-sandbox get kafkatopic
```

6) Smoke-test produce and consume inside the cluster
```bash
kubectl -n kafka-sandbox run kafka-smoke-producer \
  -it \
  --rm \
  --restart=Never \
  --image=quay.io/strimzi/kafka:1.0.0-kafka-4.2.0 \
  -- bin/kafka-console-producer.sh \
    --bootstrap-server sandbox-kafka-bootstrap.kafka-sandbox.svc:9092 \
    --topic kafka-smoke-test
```

```bash
kubectl -n kafka-sandbox run kafka-smoke-consumer \
  -it \
  --rm \
  --restart=Never \
  --image=quay.io/strimzi/kafka:1.0.0-kafka-4.2.0 \
  -- bin/kafka-console-consumer.sh \
    --bootstrap-server sandbox-kafka-bootstrap.kafka-sandbox.svc:9092 \
    --topic kafka-smoke-test \
    --from-beginning \
    --timeout-ms 10000
```

## Useful Checks

```bash
helm -n strimzi-system list

kubectl -n strimzi-system get pods -o wide

kubectl -n kafka-sandbox get pods -o wide
kubectl -n kafka-sandbox get kafka
kubectl -n kafka-sandbox get kafkanodepool
kubectl -n kafka-sandbox get kafkatopic
kubectl -n kafka-sandbox get kafkauser
kubectl -n kafka-sandbox get pvc

kubectl -n kafka-sandbox describe kafka sandbox
kubectl -n strimzi-system logs deployment/strimzi-cluster-operator --tail=100
```

## Cleanup

```bash
kubectl -n kafka-sandbox delete kafkatopic kafka-smoke-test
kubectl -n kafka-sandbox delete kafka sandbox
kubectl -n kafka-sandbox delete kafkanodepool dual-role

helm -n strimzi-system uninstall strimzi-cluster-operator
kubectl delete namespace kafka-sandbox
kubectl delete namespace strimzi-system
```
