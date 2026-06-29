provider "proxmox" {
  endpoint  = var.proxmox.endpoint
  api_token = var.proxmox.api_token

  insecure = true
}
