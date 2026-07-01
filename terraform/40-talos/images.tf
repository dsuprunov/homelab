data "talos_image_factory_extensions_versions" "talos" {
  for_each = var.talos_images

  talos_version = var.talos_version

  filters = {
    names = each.value.extensions
  }
}

resource "talos_image_factory_schematic" "talos" {
  for_each = var.talos_images

  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.talos[each.key].extensions_info.*.name
      }
    }
  })
}

data "talos_image_factory_urls" "talos" {
  for_each = var.talos_images

  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.talos[each.key].id
  platform      = each.value.platform
}

resource "proxmox_download_file" "talos_image" {
  for_each = var.talos_images

  content_type = "import"
  datastore_id = each.value.datastore_id
  node_name    = each.value.node_name

  url       = data.talos_image_factory_urls.talos[each.key].urls.disk_image
  file_name = "${each.key}-${each.value.platform}-amd64-${var.talos_version}.raw"
}
