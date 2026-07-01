output "id" {
  value = proxmox_virtual_environment_vm.vm.id
}

output "name" {
  value = var.name
}

output "ips" {
  value = [for nic in var.network_interfaces : nic.ipv4_address]
}

output "tags" {
  value = var.tags
}
