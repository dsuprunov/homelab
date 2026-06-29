output "images" {
  description = "Cloud image file IDs by image key"

  value = {
    for image_name, image in proxmox_download_file.image :
    image_name => image.id
  }
}
