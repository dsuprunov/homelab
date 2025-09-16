```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/homelab-ed25519
ssh-add -l

docker compose up --build -d

docker exec -it ansible ansible-galaxy collection list

docker exec -it ansible ansible all -m ping -i inventory.yml -o

docker compose down
```

```bash
docker exec -it ansible ansible-playbook bootstrap.yml --syntax-check
docker exec -it ansible ansible-playbook bootstrap.yml --check
docker exec -it ansible ansible-playbook bootstrap.yml --limit test-vm-1
docker exec -it ansible ansible-playbook bootstrap.yml
```

```bash
docker exec -it ansible ansible-playbook docker.yml --syntax-check
docker exec -it ansible ansible-playbook docker.yml --check
docker exec -it ansible ansible-playbook docker.yml
```

```bash
docker exec -it ansible ansible-playbook pihole.yml --syntax-check
docker exec -it ansible ansible-playbook pihole.yml --check
docker exec -it ansible ansible-playbook pihole.yml
```