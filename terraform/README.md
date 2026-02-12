
docker compose run --rm terraform init

docker compose run --rm terraform fmt -recursive

docker compose run --rm terraform validate

docker compose run --rm terraform plan

docker compose run --rm terraform apply -auto-approve

docker compose run --rm terraform destroy -auto-approve