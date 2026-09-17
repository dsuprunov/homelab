# Terraform

Terraform is split into independent root modules by purpose and lifecycle.
Each directory has its own local state.

## Layers

- `00-vm-templates` - Packer artifacts imported to Proxmox VM templates.
- `10-bootstrap` - first infrastructure VM, currently `vm-coredns`.
- `20-core-services` - core service VMs, currently Garage and Vault templates are kept disabled.
- `30-kubeadm` - kubeadm Kubernetes VMs.
- `90-sandbox` - test VMs that can be destroyed and recreated independently.

The numeric prefixes are an operator convention, not a Terraform dependency
graph. Follow the complete deployment order in [INSTALL.md](../INSTALL.md).

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

Keep credentials in `terraform/credentials.auto.tfvars`.
Use `credentials.auto.tfvars.example` as the format reference.

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
