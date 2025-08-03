output "vm_credentials" {
  description = "VM credentials"
  value = [
    for vm_name, vm_config in var.vm_configs : {
      name  = vm_name
      id    = vm_config.vm_id
      ip = vm_config.ipconfig
      username = vm_config.ciuser
      password = random_password.vm_password[vm_name].result
    }
  ]
  sensitive = true
}