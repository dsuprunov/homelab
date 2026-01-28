output "id" {
  value = proxmox_virtual_environment_vm.vm.id
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