variable "images" {
  type = map(object({
    content_type = string
    datastore_id = optional(string, "local")
    file_name    = string
    node_name    = optional(string, "pve-01")
    url          = string
  }))
}

resource "proxmox_virtual_environment_download_file" "image" {
  for_each = var.images

  content_type = each.value.content_type
  datastore_id = each.value.datastore_id
  node_name    = each.value.node_name

  url       = each.value.url
  file_name = each.value.file_name
  # overwrite           = true
  # overwrite_unmanaged = true
}

output "images" {
  description = "Cloud image file IDs by image key"
  value = {
    for image_name, r in proxmox_virtual_environment_download_file.image :
    image_name => r.id
  }
}
