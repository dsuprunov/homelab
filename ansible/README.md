```bash
docker compose up --build -d

docker exec -it ansible ansible all -m ping -i inventory.yml

docker compose down
```