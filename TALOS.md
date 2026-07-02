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
talosctl --talosconfig ~/.talos/config etcd status
talosctl --talosconfig ~/.talos/config etcd members
```

### Logs

```bash
talosctl --talosconfig ~/.talos/config logs kubelet
talosctl --talosconfig ~/.talos/config logs containerd
talosctl --talosconfig ~/.talos/config logs apid
talosctl --talosconfig ~/.talos/config dmesg
```

### Node Details

```bash
talosctl --talosconfig ~/.talos/config disks
talosctl --talosconfig ~/.talos/config mounts
talosctl --talosconfig ~/.talos/config get links
talosctl --talosconfig ~/.talos/config get addresses
talosctl --talosconfig ~/.talos/config get routes
talosctl --talosconfig ~/.talos/config usage
```

### Single Node

```bash
talosctl --talosconfig ~/.talos/config -n vm-k8s-control-01 services
talosctl --talosconfig ~/.talos/config -n vm-k8s-worker-01 logs kubelet
```

## Notes

- Talos machine config enables the built-in VIP on control plane nodes.
- Commands in "Useful Read-Only Checks" are intended for diagnostics and should
  not change cluster or infrastructure state.
