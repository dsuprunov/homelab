```bash
PUID=$(id -u) PGID=$(id -g) docker compose -f docker-compose.yml run --rm terraform init

PUID=$(id -u) PGID=$(id -g) docker compose -f docker-compose.yml run --rm terraform fmt -recursive

PUID=$(id -u) PGID=$(id -g) docker compose -f docker-compose.yml run --rm terraform validate

PUID=$(id -u) PGID=$(id -g) docker compose -f docker-compose.yml run --rm terraform plan

PUID=$(id -u) PGID=$(id -g) docker compose -f docker-compose.yml run --rm terraform apply -auto-approve

PUID=$(id -u) PGID=$(id -g) docker compose -f docker-compose.yml run --rm terraform destroy -auto-approve
```