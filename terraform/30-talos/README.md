### TBD

https://factory.talos.dev

```bash
terraform -chdir=30-talos init

terraform -chdir=30-talos validate
terraform -chdir=30-talos fmt -recursive

terraform -chdir=30-talos init
terraform -chdir=30-talos plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
terraform -chdir=30-talos apply terraform.tfplan

terraform -chdir=30-talos plan -destroy -var-file=../credentials.auto.tfvars -out terraform.tfplan
terraform -chdir=30-talos apply terraform.tfplan
```

```bash
export CONTROL_PLANE_IP=192.168.178.27

talosctl --nodes $CONTROL_PLANE_IP version --insecure
```

```bash
export CONTROL_PLANE_IP=192.168.178.27

talosctl gen config talos-proxmox-cluster https://$CONTROL_PLANE_IP:6443 --output-dir _out \
  --install-image factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.13.7 

export CONTROL_PLANE_IP=192.168.178.27
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file _out/controlplane.yaml

export WORKER_IP=192.168.178.26
export WORKER_IP=192.168.178.59
export WORKER_IP=192.168.178.53
talosctl apply-config --insecure --nodes $WORKER_IP --file _out/worker.yaml
```

```bash
export CONTROL_PLANE_IP=192.168.178.27

export TALOSCONFIG="_out/talosconfig"
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $CONTROL_PLANE_IP

talosctl bootstrap

mkdir -m 700 ~/.kube
talosctl kubeconfig ~/.kube/talos

kubectl --kubeconfig ~/.kube/talos get pods -A
```
