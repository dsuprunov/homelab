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
    tags        = optional(list(string), [])
  }))
}

variable "lxc" {
  type = map(object({
    vmid        = number
    template    = string
    target_node = string
    start       = bool
    onboot      = bool
    memory      = number
    disk        = string
    cores       = number
    ip          = string
    gw          = optional(string)
    nameserver  = optional(string)
    ssh_key     = string
    tags        = optional(list(string), [])
  }))
}