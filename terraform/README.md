```bash
docker compose -f docker-compose.yml run --rm terraform init

docker compose -f docker-compose.yml run --rm terraform fmt -recursive

docker compose -f docker-compose.yml run --rm terraform validate

docker compose -f docker-compose.yml run --rm terraform plan
```