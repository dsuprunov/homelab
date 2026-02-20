output "id" {
  value = proxmox_virtual_environment_container.ct.id
}

output "name" {
  value = var.name
}

output "ip" {
  value = var.ipv4_address
}

output "tags" {
  value = var.tags
}

