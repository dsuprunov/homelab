provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token

  insecure = true
}

provider "dns" {
  update {
    server        = var.dns_update_server
    port          = var.dns_update_port
    key_name      = var.dns_update_key_name
    key_secret    = var.dns_update_key_secret
    key_algorithm = var.dns_update_key_algorithm
  }
}