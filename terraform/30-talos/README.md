# Talos

This Terraform root module creates Proxmox VMs and bootstraps the Talos
Kubernetes cluster without manual Talos provisioning.

## Workflow

```bash
terraform -chdir=30-talos init

terraform -chdir=30-talos fmt -recursive
terraform -chdir=30-talos validate

terraform -chdir=30-talos plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
terraform -chdir=30-talos apply terraform.tfplan

terraform -chdir=30-talos plan -destroy -var-file=../credentials.auto.tfvars -out terraform.tfplan
terraform -chdir=30-talos apply terraform.tfplan
```

## Kubeconfig

```bash
install -d -m 700 ~/.kube
terraform -chdir=30-talos output -raw kubeconfig > ~/.kube/config
chmod 600 ~/.kube/config

kubectl get pods -A
```

## Talosconfig

```bash
install -d -m 700 ~/.talos
terraform -chdir=30-talos output -raw talosconfig > ~/.talos/config
chmod 600 ~/.talos/config

talosctl --nodes 192.168.178.231 health
```
