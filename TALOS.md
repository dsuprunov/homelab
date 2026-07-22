# Talos

## Target State

- Talos version: `v1.13.5`
- Kubernetes version: `v1.36.2`
- Control plane: `vm-k8s-control-01..03`
- Workers: `vm-k8s-worker-01..03`
- Kubernetes API VIP: `192.168.178.230`
- Kubernetes API DNS: `k8s-api.home.arpa`
- Node DNS domain: `home.arpa`
- Images: `talos_control`, `talos_worker`
- Platform: `nocloud`
- System extension
  - `qemu-guest-agent`
- Bootstrap CNI: disabled (`cluster.network.cni.name: none`)
- `kube-proxy`: disabled (`cluster.proxy.disabled: true`)
- Gateway API CRDs: `1.4.1`
- Cilium VIP pool: `192.168.178.246...250`
- Cilium ingress gateway IP: `192.168.178.246`
- Cluster CNI: Cilium `1.19.5` with
  - kube-proxy replacement
  - L2 announcements
  - Gateway API enabled

## Lifecycle

```bash
terraform -chdir=/homelab/terraform/30-talos init
terraform -chdir=/homelab/terraform/30-talos plan -var-file=../credentials.auto.tfvars
terraform -chdir=/homelab/terraform/30-talos apply -var-file=../credentials.auto.tfvars
terraform -chdir=/homelab/terraform/30-talos destroy -var-file=../credentials.auto.tfvars
```

## Write Kubeconfig

```bash
mkdir -p ~/.kube
terraform -chdir=/homelab/terraform/30-talos output -raw kubeconfig > ~/.kube/config
chmod 600 ~/.kube/config
```

## Write Talosconfig

```bash
mkdir -p ~/.talos
terraform -chdir=/homelab/terraform/30-talos output -raw talosconfig > ~/.talos/config
chmod 600 ~/.talos/config
```

## Validate

```bash
talosctl --nodes vm-k8s-control-01.home.arpa health

kubectl get nodes -o wide
```

## Useful Checks

### Talos

```bash
talosctl dashboard

talosctl version
talosctl services
talosctl get members
```

### Etcd

```bash
talosctl --nodes vm-k8s-control-01.home.arpa,vm-k8s-control-02.home.arpa,vm-k8s-control-03.home.arpa etcd status
talosctl --nodes vm-k8s-control-01.home.arpa,vm-k8s-control-02.home.arpa,vm-k8s-control-03.home.arpa etcd members
```

### Logs

```bash
talosctl logs kubelet
talosctl logs containerd
talosctl logs apid
talosctl dmesg

talosctl -n vm-k8s-control-01.home.arpa services
talosctl -n vm-k8s-control-01.home.arpa logs kubelet
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
