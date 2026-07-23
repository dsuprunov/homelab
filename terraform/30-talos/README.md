### TBD

https://factory.talos.dev

```bash
terraform -chdir=30-talos init

terraform -chdir=30-talos validate
terraform -chdir=30-talos fmt -recursive

terraform -chdir=30-talos init
terraform -chdir=30-talos plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
terraform -chdir=30-talos apply terraform.tfplan

terraform -chdir=30-talos plan -destroy -var-file=../credentials.auto.tfvars -out terraform.tfplan
terraform -chdir=30-talos apply terraform.tfplan
```
