## Start ssh-agent and load SSH key

```bash
eval "$(ssh-agent -s)"

ssh-add ~/.ssh/homelab-ed25519

ssh-add -l
```

## Run Ansible commands in Docker

```bash
docker compose build --no-cache

docker compose run --rm ansible ansible --version

docker compose run --rm ansible ansible-inventory --graph

docker compose run --rm ansible ansible -m ping vms

docker compose run --rm ansible ansible-playbook playbooks/*
```

### Install Pi-hole

```bash
docker compose run --rm ansible ansible-playbook playbooks/pihole.yaml
```

### Prepare k8s node

```bash
docker compose run --rm ansible ansible-playbook playbooks/k8s.yaml
```