# Talos

## Target State

- Talos version: `v1.13.5`
- Kubernetes version: `v1.36.2`
- Control plane: `vm-k8s-control-01..03`
- Workers: `vm-k8s-worker-01..03`
- Kubernetes API VIP: `192.168.178.230`
- Kubernetes API DNS: `k8s-api.home.arpa`
- Images: `talos_control`, `talos_worker`
- Platform: `nocloud`
- System extension
  - `qemu-guest-agent`

## Lifecycle

```bash
terraform -chdir=/homelab/terraform/40-talos init
terraform -chdir=/homelab/terraform/40-talos plan -var-file=../credentials.auto.tfvars
terraform -chdir=/homelab/terraform/40-talos apply -var-file=../credentials.auto.tfvars
terraform -chdir=/homelab/terraform/40-talos destroy -var-file=../credentials.auto.tfvars
```

## Write Kubeconfig

```bash
mkdir -p ~/.kube
terraform -chdir=/homelab/terraform/40-talos output -raw kubeconfig > ~/.kube/config
chmod 600 ~/.kube/config
```

## Write Talosconfig

```bash
mkdir -p ~/.talos
terraform -chdir=/homelab/terraform/40-talos output -raw talosconfig > ~/.talos/config
chmod 600 ~/.talos/config
```

## Validate

```bash
kubectl get nodes -o wide

talosctl --nodes 192.168.178.231 health
```

## Useful Checks

### Talos

```bash
talosctl version
talosctl services
talosctl dashboard
talosctl get members
```

### Etcd

```bash
talosctl --nodes 192.168.178.231,192.168.178.232,192.168.178.233 etcd status
talosctl --nodes 192.168.178.231,192.168.178.232,192.168.178.233 etcd members
```

### Logs

```bash
talosctl logs kubelet
talosctl logs containerd
talosctl logs apid
talosctl dmesg

talosctl -n 192.168.178.231 services
talosctl -n 192.168.178.231 logs kubelet
```

### Node Details

```bash
talosctl get disks
talosctl get systemdisk
talosctl get discoveredvolumes
talosctl mounts
talosctl get links
talosctl get addresses
talosctl get routes
talosctl usage
```
