# Flux GitOps

Practical guide for:
- Initial Flux bootstrap to GitHub over SSH deploy key.
- Clean cluster reinstall and reconnect to existing Flux repo state.

Notes:
- `Initial Flux Bootstrap` is manual by definition when repo does not yet contain Flux artifacts, or when cluster/repo state is completely new.
- `Cluster Reinstall and Reconnect` below is also documented as manual for clarity. In normal operations this should be automated via Ansible role.

## Table of Contents

1. [Initial Flux Bootstrap](#initial-flux-bootstrap)
2. [Cluster Reinstall and Reconnect](#cluster-reinstall-and-reconnect)

## Initial Flux Bootstrap

Target:
- repo: `ssh://git@github.com/dsuprunov/homelab.git`
- branch: `main`
- path: `flux/clusters/homelab`
- namespace: `flux-system`

### 1) Install Flux CLI

```bash
curl -s https://fluxcd.io/install.sh | sudo bash
flux --version
```

### 2) Generate SSH deploy key locally

```bash
ssh-keygen -t ed25519 -C "homelab-github-flux" -f "$HOME/.ssh/homelab-github-flux-ed25519" -N ""
```

### 3) Add public key to GitHub as Deploy Key

1. Open `https://github.com/dsuprunov/homelab`.
2. Go to `Settings` -> `Deploy keys` -> `Add deploy key`.
3. Paste `~/.ssh/homelab-github-flux-ed25519.pub`.
4. Enable `Allow write access`.

### 4) Quick SSH check

```bash
ssh -T git@github.com \
  -i "$HOME/.ssh/homelab-github-flux-ed25519" \
  -o IdentitiesOnly=yes \
  -o StrictHostKeyChecking=accept-new
```

### 5) Bootstrap Flux

```bash
flux bootstrap git \
  --url=ssh://git@github.com/dsuprunov/homelab.git \
  --branch=main \
  --path=flux/clusters/homelab \
  --private-key-file="$HOME/.ssh/homelab-github-flux-ed25519" \
  --namespace=flux-system \
  --silent
```

### 6) Verify reconciliation

```bash
flux check
kubectl -n flux-system get pods
flux get sources git -A
flux get kustomizations -A
```

### 7) Artifacts you MUST keep

Store outside (backup/secure host):

1. `~/.ssh/homelab-github-flux-ed25519` (private key)
2. `~/.ssh/homelab-github-flux-ed25519.pub` (public key)
3. Repo coordinates:
   - URL: `ssh://git@github.com/dsuprunov/homelab.git`
   - branch: `main`
   - path: `flux/clusters/homelab`
4. Flux identity:
   - namespace: `flux-system`
   - `GitRepository`: `flux-system`
   - `Kustomization`: `flux-system`

```bash
scp \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  ubuntu@vm-k8s-control-01.home.arpa:~/.ssh/homelab-github-flux-ed25519* ~/.ssh/
```

### 8) Optional cleanup

After successful bootstrap and validation, local key files can be removed from the node.
Do this only if keys are already backed up.

```bash
rm -f ~/.ssh/homelab-github-flux-ed25519*
```

## Cluster Reinstall and Reconnect

Use this only to understand/validate the process manually after a clean reinstall.
Target is to reconnect a new cluster to already existing Flux state in Git.

Prerequisites:
1. Repo already contains Flux artifacts in `flux/clusters/homelab/flux-system/`.
2. You have the same deploy key used for this repo (`homelab-github-flux-ed25519`).

### 1) Restore SSH deploy key on the new control node

Run on backup host to copy keys to new control node

```bash
scp \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  ~/.ssh/homelab-github-flux-ed25519* ubuntu@vm-k8s-control-01.home.arpa:~/.ssh/
```

### 2) SSH access check

```bash
ssh -T git@github.com \
  -i "$HOME/.ssh/homelab-github-flux-ed25519" \
  -o IdentitiesOnly=yes \
  -o StrictHostKeyChecking=accept-new
```

### 3) Install Flux CLI

```bash
curl -s https://fluxcd.io/install.sh | sudo bash
flux --version
```

### 4) Reconnect cluster to existing Git state

Use exactly the same repo coordinates as in initial bootstrap.

```bash
flux bootstrap git \
  --url=ssh://git@github.com/dsuprunov/homelab.git \
  --branch=main \
  --path=flux/clusters/homelab \
  --private-key-file="$HOME/.ssh/homelab-github-flux-ed25519" \
  --namespace=flux-system \
  --silent
```

### 5) Validate reconciliation

```bash
flux check
kubectl -n flux-system get pods
flux get sources git -A
flux get kustomizations -A
```

### 6) Optional cleanup

After reconnect is successful, remove local key files from this node if backup copy exists.

```bash
rm -f ~/.ssh/homelab-github-flux-ed25519*
```
