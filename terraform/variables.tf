variable "proxmox" {
  type = object({
    endpoint  = string
    api_token = string
  })
  sensitive = true
}
