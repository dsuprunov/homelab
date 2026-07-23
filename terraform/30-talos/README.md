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
export CONTROL_PLANE_IP=192.168.178.45

talosctl --nodes $CONTROL_PLANE_IP version --insecure
```

```bash
export CONTROL_PLANE_IP=192.168.178.45

talosctl gen config talos-proxmox-cluster https://$CONTROL_PLANE_IP:6443 --output-dir _talos \
  --install-image factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.13.7 

export CONTROL_PLANE_IP=192.168.178.45
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file _talos/controlplane.yaml

export WORKER_IP=192.168.178.44
export WORKER_IP=192.168.178.31
export WORKER_IP=192.168.178.37
talosctl apply-config --insecure --nodes $WORKER_IP --file _talos/worker.yaml
```

```bash
export CONTROL_PLANE_IP=192.168.178.45

export TALOSCONFIG="_talos/talosconfig"
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $CONTROL_PLANE_IP

talosctl bootstrap

mkdir -m 700 ~/.kube
talosctl kubeconfig ~/.kube/talos

kubectl --kubeconfig ~/.kube/talos get pods -A
```
