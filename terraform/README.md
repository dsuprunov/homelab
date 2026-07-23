# Terraform

Terraform is split into independent root modules by purpose and lifecycle.
Each directory has its own local state.

## Layers

- `00-vm-templates` - Packer artifacts imported to Proxmox VM templates.
- `10-bootstrap` - first infrastructure VM, currently `vm-coredns`.
- `20-core-services` - core service VMs, currently Garage and Vault templates are kept disabled.
- `30-kubeadm` - kubeadm Kubernetes VMs.
- `30-talos` - Talos Kubernetes VMs.
- `90-sandbox` - test VMs that can be destroyed and recreated independently.

The numeric prefixes are an operator convention, not a Terraform dependency
graph. The recommended first deployment order is:

## Images And Templates

Packer owns base image provisioning. It starts upstream Ubuntu/Debian cloud
images with QEMU/TCG, installs `qemu-guest-agent`, cleans cloud-init state, and
writes versioned `.qcow2` artifacts under:

```text
packer/artifacts/
```

`00-vm-templates` owns Proxmox VM templates created from those artifacts. VM
layers do not download or import cloud images directly. They clone templates
through aliases exported by the local state of `00-vm-templates`.

## Credentials

Credentials stay in the shared file:

```text
terraform/credentials.auto.tfvars
```

## Deploy

```bash
packer/build.sh ubuntu_26_04
packer/build.sh debian_13

terraform -chdir=00-vm-templates init
terraform -chdir=00-vm-templates plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
terraform -chdir=00-vm-templates apply terraform.tfplan

terraform -chdir=10-bootstrap init
terraform -chdir=10-bootstrap plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
terraform -chdir=10-bootstrap apply terraform.tfplan

terraform -chdir=20-core-services init
terraform -chdir=20-core-services plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
terraform -chdir=20-core-services apply terraform.tfplan

terraform -chdir=30-kubeadm init
terraform -chdir=30-kubeadm plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
terraform -chdir=30-kubeadm apply terraform.tfplan

terraform -chdir=30-talos init
terraform -chdir=30-talos plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
terraform -chdir=30-talos apply terraform.tfplan

terraform -chdir=90-sandbox init
terraform -chdir=90-sandbox plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
terraform -chdir=90-sandbox apply terraform.tfplan
```

## Add Image Version

Build a new Packer artifact using `YYYYMMDD` version naming:

```bash
packer/build.sh ubuntu_26_04 20260722
```

Add a new immutable entry to `00-vm-templates/images.auto.tfvars`, then apply
`00-vm-templates`. VM layers use image aliases, not raw artifact names:

```hcl
image = "ubuntu_26_04"
```

## Add VM

Add a VM to the `vms` map in the right layer:

- `10-bootstrap` for first infrastructure dependencies like DNS.
- `20-core-services` for shared service VMs.
- `30-kubeadm` for kubeadm Kubernetes nodes.
- `30-talos` for Talos Kubernetes nodes.
- `90-sandbox` for temporary test VMs.
