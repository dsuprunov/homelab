variable "proxmox" {
  type = object({
    endpoint  = string
    api_token = string
  })
  sensitive = true
}

variable "dns" {
  type = object({
    update_server        = string
    update_port          = optional(number, 53)
    update_key_name      = string
    update_key_secret    = string
    update_key_algorithm = optional(string, "hmac-sha256")
  })
  sensitive = true
}