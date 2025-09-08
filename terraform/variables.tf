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

variable "vm" {
  type = map(object({
    vmid        = number
    name        = string
    template    = string
    target_node = string
    state       = string
    onboot      = bool
    memory      = number
    disk        = string
    cores       = number
    ipconfig    = string
    nameserver  = optional(string)
    user        = string
    ssh_key     = string
  }))
}

variable "ct" {
  type = map(object({
    vmid        = number
    name        = string
    template    = string
    target_node = string
    start       = string
    onboot      = bool
    memory      = number
    disk        = string
    cores       = number
    ip          = string
    gw          = optional(string)
    nameserver  = optional(string)
    ssh_key     = string
  }))
}