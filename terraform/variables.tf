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

# variable "proxmox_root_username" {
#   type      = string
#   sensitive = true
# }
#
# variable "proxmox_root_password" {
#   type      = string
#   sensitive = true
# }

variable "vm" {
  type = map(object({
    vmid        = number
    tags        = optional(list(string), [])
    template    = string
    target_node = optional(string, "pve")
    state       = optional(string, "running")
    onboot      = optional(bool, true)
    memory      = number
    balloon     = optional(number)
    disk        = string
    cores       = number
    ipconfig    = string
    nameserver  = optional(string)
    user        = string
    ssh_key     = string
    attachments = optional(object({
      scsi1 = optional(object({
        disk = optional(object({
          storage    = string
          size       = string
          iothread   = optional(bool, true)
          discard    = optional(bool, true)
          emulatessd = optional(bool, true)
        }))
        passthrough = optional(object({
          file       = string
          iothread   = optional(bool, true)
          discard    = optional(bool, true)
          emulatessd = optional(bool, true)
        }))
      }))
    }))
  }))
}