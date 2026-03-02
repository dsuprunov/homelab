docker compose run --rm terraform init

docker compose run --rm terraform fmt -recursive

docker compose run --rm terraform validate

docker compose run --rm terraform plan

docker compose run --rm terraform apply -auto-approve

docker compose run --rm terraform destroy -auto-approve

# DNS (RFC2136 + TSIG, hashicorp/dns)
# - configure TSIG in credentials.auto.tfvars (see credentials.auto.tfvars.example)
# - manage records in dns.auto.tfvars
