# Homelab

This repository manages a personal homelab.

It contains Terraform code for Proxmox resources, Ansible playbooks for host and
Kubernetes setup.

## For Agents

Use this file as the first context file when working in this repository.

Keep changes small and direct. Do not rewrite unrelated files. Do not remove user
changes unless the user asks for it.

## Repository Map

- `terraform/` - Proxmox infrastructure code.
- `ansible/` - Ansible inventory, playbooks, and roles.
- `docker/` - Local container environment for running the homelab toolchain.
- `INSTALL.md` - Setup and daily command guide.
- `INFRA.md`, `PROXMOX.md`, `VAULT.md`, `VAULT-VSO.md`, `GARAGE.md` - Topic notes.

## Important Rules

- Do not commit secrets, tokens, private keys, or generated kubeconfigs.
- Treat `terraform/credentials.auto.tfvars` and `terraform/**/*.tfstate*` as sensitive.
- Preserve the existing Terraform, Ansible, and Flux structure.
- Prefer minimal patches over broad refactors.
- Run checks before finalizing changes when the required tools are available.

## Common Checks

Run the checks that match the files you changed.

## How To Use

See `INSTALL.md` for setup steps and common commands.
See `terraform/README.md` for Terraform layers and state boundaries.
