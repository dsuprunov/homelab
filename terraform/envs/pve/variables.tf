variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token" {
  type = string
  sensitive   = true
}

variable "ssh_keys" {
  type        = string
  sensitive   = true
}

variable vm_configs {
  type = map(object({
    vm_id       = number
    name        = string
    memory      = number
    vm_state    = string
    onboot      = bool
    startup     = string
    ipconfig    = string
    ciuser      = string
    cores       = number
    bridge      = string
    network_tag = number
  }))

  default = {
    "vm-201" = {
      vm_id       = 201
      name        = "vm-201"
      memory      = 1024
      vm_state    = "stopped"
      onboot      = true
      startup     = "order=2"
      ipconfig    = "ip=192.168.178.211/24,gw=192.168.178.1"
      ciuser      = "dms"
      cores       = 1
      bridge      = "vmbr0"
      network_tag = 0
    }
  }
}