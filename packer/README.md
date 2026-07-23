# Packer Images

Packer builds versioned image artifacts for Proxmox.
The artifacts are local `.qcow2` files consumed by `terraform/00-vm-templates`.

## Build

Run builds from the repository root inside the managed container:

```bash
packer/build.sh ubuntu_24_04 20260722
packer/build.sh ubuntu_26_04 20260722
packer/build.sh debian_13 20260722
```

If the version argument is omitted, the script uses the current UTC date in
`YYYYMMDD` format.

## Artifacts

Artifacts are written under `packer/artifacts/`:

```text
packer/artifacts/ubuntu-24.04/20260722/ubuntu-24.04.qcow2
packer/artifacts/ubuntu-26.04/20260722/ubuntu-26.04.qcow2
packer/artifacts/debian-13/20260722/debian-13.qcow2
```
