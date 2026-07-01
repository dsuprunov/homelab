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
- System extension: `qemu-guest-agent`

## Apply Order

```bash
terraform -chdir=/homelab/terraform/40-talos init
terraform -chdir=/homelab/terraform/40-talos plan -var-file=../credentials.auto.tfvars
terraform -chdir=/homelab/terraform/40-talos apply -var-file=../credentials.auto.tfvars
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
kubectl --kubeconfig ~/.kube/config get nodes -o wide
talosctl --talosconfig ~/.talos/config health
```

## Notes

- Talos machine config enables the built-in VIP on control plane nodes.

