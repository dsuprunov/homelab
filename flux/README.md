# Flux GitOps

This document is only for understanding and validating the Flux bootstrap/reconnect process.
In normal operation, Ansible role `k8s_addon_flux` handles everything automatically.

## Actual behavior

- Authentication for GitHub API is done with `GITHUB_TOKEN` (PAT).
- With `--token-auth=false`, Flux uses SSH deploy key for Git access, but key handling is done by Flux bootstrap itself.
- Idempotency is provided by Flux bootstrap:
  - empty `flux/` path: create and commit Flux artifacts;
  - existing artifacts: reconnect and reconcile;
  - drift: reconcile resources back to desired state.

### 1) Create fine-grained PAT

Use a GitHub `fine-grained personal access token`.

1. Open `https://github.com/settings/personal-access-tokens/new`.
2. Set:
   - Resource owner: `dsuprunov`
   - Repository access: `Only select repositories` -> `homelab`
   - Expiration: short/rotated value
3. Set repository permissions:
   - `Contents`: `Read and write`
   - `Administration`: `Read and write` (required for deploy key create/update during bootstrap)
   - `Metadata`: `Read`
4. Click `Generate token` and copy it once.

### 2) Prepare PAT

Create/export PAT before running bootstrap:

```bash
export GITHUB_TOKEN='<your_pat>'
```

Quick check:

```bash
curl -sSf -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/user >/dev/null
```

### 3) Install Flux CLI

```bash
curl -s https://fluxcd.io/install.sh | sudo bash
flux --version
```

### 4) Run bootstrap

```bash
flux bootstrap github \
  --owner=dsuprunov \
  --repository=homelab \
  --branch=main \
  --path=flux \
  --personal \
  --reconcile=true \
  --token-auth=false
```

### 5) Verify reconciliation

```bash
flux check
kubectl -n flux-system get pods
flux get sources git -A
flux get kustomizations -A
```

### 6) Cleanup shell environment

```bash
unset GITHUB_TOKEN
```
