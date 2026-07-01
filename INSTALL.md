# Homelab

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

if command -v flux >/dev/null 2>&1; then
  source <(flux completion zsh)
fi

if command -v talosctl >/dev/null 2>&1; then
  source <(talosctl completion zsh)
fi
EOF

install -D -m 600 /dev/stdin ~/.homelab/.env <<'EOF'
# GitHub PAT for Flux bootstrap and deploy key management
# GITHUB_TOKEN=github_pat_xxxxxxxxxxxxxxxxxxxx
EOF
```

## Build-Run-Repeat

```bash
eval "$(ssh-agent -s)"; ssh-add ~/.ssh/homelab-ed25519

HOST_UID="$(id -u)" HOST_GID="$(id -g)" docker compose -f docker/compose.yaml build --no-cache

HOST_UID="$(id -u)" HOST_GID="$(id -g)" docker compose -f docker/compose.yaml run --rm homelab
```
