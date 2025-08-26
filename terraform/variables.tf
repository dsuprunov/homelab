variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "vms" {
  type = map(object({
    vmid        = number
    name        = string
    template    = string
    target_node = string
    memory      = number
    disk        = string
    cores       = number
    ipconfig    = string
    nameserver  = string
    user        = string
    ssh_key     = string
  }))
}