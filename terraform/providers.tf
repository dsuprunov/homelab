provider "proxmox" {
  endpoint  = var.proxmox.endpoint
  api_token = var.proxmox.api_token

  insecure = true
}

provider "dns" {
  update {
    server        = var.dns.update_server
    port          = var.dns.update_port
    key_name      = var.dns.update_key_name
    key_secret    = var.dns.update_key_secret
    key_algorithm = var.dns.update_key_algorithm
  }
}