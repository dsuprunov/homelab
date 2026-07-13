# Longhorn Operations

## Install

The `k8s_node_longhorn` role prepares `/dev/sdb` on every host in the
`k8s_node_longhorn` inventory group. It installs the required packages,
creates and mounts `/dev/sdb1` at `/var/lib/longhorn`, then configures the
Kubernetes Node label and disk annotation after the worker nodes join the
cluster.

Argo CD installs Longhorn `1.12.0` in `longhorn-system` through the
`platform-storage` project.

### Verify node preparation

```bash
kubectl get nodes -L node.longhorn.io/create-default-disk

kubectl get nodes \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.node\.longhorn\.io/default-disks-config}{"\n"}{end}'
```

### Verify Argo CD and Longhorn

```bash
kubectl -n argocd get application longhorn
kubectl -n longhorn-system get pods -o wide
kubectl get storageclass longhorn longhorn-2-replicas-delete
kubectl -n longhorn-system get settings.longhorn.io default-replica-count default-data-path create-default-disk-labeled-nodes
```

### Open Longhorn UI

Open `https://longhorn.k8s.home.arpa`.

## Useful Checks

```bash
kubectl -n argocd get application longhorn
kubectl -n longhorn-system get pods -o wide
kubectl -n longhorn-system get volumes.longhorn.io
kubectl -n longhorn-system get replicas.longhorn.io
kubectl -n longhorn-system get nodes.longhorn.io
kubectl -n longhorn-system get httproute longhorn
kubectl -n cilium-gateway get certificate longhorn-tls
```
