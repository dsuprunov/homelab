# Flux GitOps

Practical guide for:
- Initial Flux bootstrap to GitHub over SSH deploy key.
- Clean cluster reinstall and reconnect to existing Flux repo state.

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

## Cluster Reinstall and Reconnect

TODO: add full step-by-step runbook for clean cluster reinstall and reconnect to the existing Flux state in Git.

Planned scope:
1. Restore private key to new control node.
2. Reinstall Flux CLI.
3. Run `flux bootstrap git` with the same URL/branch/path/namespace.
4. Verify reconciliation health.
