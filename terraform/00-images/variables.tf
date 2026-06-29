variable "proxmox" {
  type = object({
    endpoint  = string
    api_token = string
  })
  sensitive = true
}

variable "images" {
  type = map(object({
    content_type = string
    datastore_id = optional(string, "local")
    file_name    = string
    node_name    = optional(string, "pve-01")
    url          = string
  }))
}
