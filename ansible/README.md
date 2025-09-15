```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/homelab-ed25519
ssh-add -l
```

```bash
docker compose up --build -d

docker exec -it ansible ansible all -m ping -i inventory.yml -o

docker compose down
```