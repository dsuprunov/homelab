resource "proxmox_download_file" "image" {
  for_each = var.images

  content_type = each.value.content_type
  datastore_id = each.value.datastore_id
  node_name    = each.value.node_name

  url       = each.value.url
  file_name = each.value.file_name
  # overwrite           = true
  # overwrite_unmanaged = true
}
