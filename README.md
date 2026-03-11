# homelab

## Install

```bash
#
# zsh
#
install -D -m 600 /dev/null ~/.homelab/.zsh_history
install -D -m 644 /dev/stdin ~/.homelab/.zshrc <<'EOF'
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

autoload -Uz colors && colors
autoload -Uz compinit
compinit

setopt PROMPT_SUBST
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS

git_prompt_info() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

  local branch dirty
  branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return

  if ! git diff --no-ext-diff --quiet --ignore-submodules 2>/dev/null || \
     ! git diff --no-ext-diff --cached --quiet --ignore-submodules 2>/dev/null; then
    dirty='*'
  fi

  printf ' %%F{magenta}[%s%s]%%f' "$branch" "$dirty"
}

PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f$(git_prompt_info) %F{green}%#%f '

if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

if command -v helm >/dev/null 2>&1; then
  source <(helm completion zsh)
fi
EOF
```

## Build-Run-Repeat

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/homelab-ed25519

HOST_UID="$(id -u)" HOST_GID="$(id -g)" docker compose -f docker/compose.yaml build --no-cache

HOST_UID="$(id -u)" HOST_GID="$(id -g)" docker compose -f docker/compose.yaml run --rm homelab
```

## Terraform 

```bash
cd /homelab/terraform

terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```

## Ansible

```bash
cd /homelab/ansible

ansible --version
ansible-galaxy collection list
ansible-inventory --graph
ansible -m ping vms
ansible-playbook playbooks/k8s.yaml --syntax-check
ansible-playbook playbooks/k8s.yaml
```

## kubectl

```bash
kubectl version --client
kubectl get nodes
```

## Helm

```bash
helm version
helm plugin list
helm list -A
```
