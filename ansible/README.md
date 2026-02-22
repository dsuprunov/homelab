## Start ssh-agent and load SSH key

```bash
eval "$(ssh-agent -s)"

ssh-add ~/.ssh/homelab-ed25519
ssh-add ~/.ssh/homelab-github-ed25519 

ssh-add -l
```

## GitHub Personal Access Token for Flux

Flux bootstrap needs a GitHub Personal Access Token (`GITHUB_TOKEN`).

Required repository permissions for the token:

1. `Contents`: `Read and write` (Flux writes and updates files in the repository.)
2. `Metadata`: `Read-only` (GitHub API needs repository metadata access.)
3. `Administration`: `Read and write` (Flux bootstrap creates repository deploy key)

How to create this token in GitHub:

1. `GitHub Account Settings` -> `Developer settings` -> `Personal access tokens`
2. Select your repository.
3. Set the permissions listed above.
4. Create the token and save it.

How to pass token to Docker Compose:

1. Use `ansible/.env` file (recommended)
2. Or set it in current shell environment:

```bash
export GITHUB_TOKEN=your_token_here
```

## Run Ansible commands in Docker

```bash
docker compose build --no-cache

docker compose run --rm ansible ansible --version

docker compose run --rm ansible ansible-inventory --graph

docker compose run --rm ansible ansible -m ping vms

docker compose run --rm ansible ansible-playbook playbooks/*
```

## Run k8s playbook

```bash
docker compose run --rm ansible ansible-playbook playbooks/k8s.yaml
```

## Run only Flux role from k8s playbook

```bash
docker compose run --rm ansible ansible-playbook playbooks/k8s.yaml --tags flux
```
