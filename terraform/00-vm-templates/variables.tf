variable "proxmox" {
  type = object({
    endpoint  = string
    api_token = string
  })
  sensitive = true
}

variable "image_versions" {
  type = map(object({
    artifact_checksum      = optional(string, null)
    artifact_file_name     = optional(string, null)
    artifact_path          = string
    boot_disk_size         = number
    cloudinit_datastore_id = optional(string, "local-lvm")
    import_datastore_id    = optional(string, "local")
    node_name              = optional(string, "pve-01")
    tags                   = optional(list(string), [])
    template_datastore_id  = optional(string, "local-lvm")
    template_name          = string
    template_vm_id         = number
  }))
}

variable "image_aliases" {
  type = map(string)

  validation {
    condition = alltrue([
      for image_version in values(var.image_aliases) :
      contains(keys(var.image_versions), image_version)
    ])
    error_message = "Every image_aliases value must reference a key from image_versions."
  }
}
