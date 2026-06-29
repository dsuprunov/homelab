# Terraform

Terraform is split into independent root modules by purpose and lifecycle.
Each directory has its own local state.

## Layers

- `00-images` - cloud images downloaded to Proxmox.
- `10-bootstrap` - first infrastructure VM, currently `vm-coredns`.
- `20-core-services` - core service VMs, currently Garage and Vault templates are kept disabled.
- `30-kubeadm` - kubeadm Kubernetes VMs.
- `40-talos` - Talos Kubernetes VMs.
- `90-sandbox` - test VMs that can be destroyed and recreated independently.

The numeric prefixes are an operator convention, not a Terraform dependency
graph. The recommended first deployment order is:

```text
00-images
10-bootstrap
20-core-services
30-kubeadm
40-talos
90-sandbox
```

After images and bootstrap are created, the other functional layers are managed
independently. kubeadm and Talos are separate VM groups and have separate state.
Sandbox can be destroyed and recreated without touching the other VM layers.

## Images

`00-images` owns the Proxmox cloud images. VM layers do not download images.
They read image file IDs from the local state of `00-images`:

Do not destroy `00-images` while other layers still use images created by it.
Those VM layers refer to the uploaded Proxmox files.

## Credentials

Credentials stay in the shared file:

```text
terraform/credentials.auto.tfvars
```

Pass it explicitly from each layer:

```bash
terraform -chdir=00-images apply -var-file=../credentials.auto.tfvars
```

## Deploy

```bash
terraform -chdir=00-images init
terraform -chdir=00-images apply -var-file=../credentials.auto.tfvars

terraform -chdir=10-bootstrap init
terraform -chdir=10-bootstrap apply -var-file=../credentials.auto.tfvars

terraform -chdir=20-core-services init
terraform -chdir=20-core-services apply -var-file=../credentials.auto.tfvars

terraform -chdir=30-kubeadm init
terraform -chdir=30-kubeadm apply -var-file=../credentials.auto.tfvars

terraform -chdir=40-talos init
terraform -chdir=40-talos apply -var-file=../credentials.auto.tfvars

terraform -chdir=90-sandbox init
terraform -chdir=90-sandbox apply -var-file=../credentials.auto.tfvars
```

## One Layer

Plan, apply, or destroy one layer from the repository root:

```bash
terraform -chdir=90-sandbox plan -var-file=../credentials.auto.tfvars
terraform -chdir=90-sandbox apply -var-file=../credentials.auto.tfvars
terraform -chdir=90-sandbox destroy -var-file=../credentials.auto.tfvars
```

## Add Image

Add a new entry to `00-images/images.auto.tfvars`, then apply `00-images`.
VMs can use it by setting `image` to the new image key.

## Add VM

Add a VM to the `vms` map in the right layer:

- `10-bootstrap` for first infrastructure dependencies like DNS.
- `20-core-services` for shared service VMs.
- `30-kubeadm` for kubeadm Kubernetes nodes.
- `40-talos` for Talos Kubernetes nodes.
- `90-sandbox` for temporary test VMs.

Create a new root module only when the VM group has a different lifecycle and
should have its own state.

## Checks

```bash
terraform fmt -recursive
terraform -chdir=00-images validate
```
