```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/homelab-ed25519
ssh-add -l
```

```bash
docker compose up --build -d

docker exec -it ansible ansible all -m ping -i inventory.yml -o

docker exec -it ansible ansible-playbook bootstrap.yml --syntax-check
docker exec -it ansible ansible-playbook bootstrap.yml --check

docker exec -it ansible ansible-playbook bootstrap.yml --limit test-vm-1

docker exec -it ansible ansible-playbook bootstrap.yml

docker compose down
```