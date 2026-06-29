data "terraform_remote_state" "images" {
  backend = "local"

  config = {
    path = "${path.root}/../00-images/terraform.tfstate"
  }
}
