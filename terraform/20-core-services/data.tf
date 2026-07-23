data "terraform_remote_state" "templates" {
  backend = "local"

  config = {
    path = "${path.root}/../00-vm-templates/terraform.tfstate"
  }
}
