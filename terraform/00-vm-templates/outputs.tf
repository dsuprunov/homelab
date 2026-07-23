output "templates" {
  description = "Proxmox template IDs by image alias"

  value = {
    for image_alias, image_version in var.image_aliases :
    image_alias => {
      name    = proxmox_virtual_environment_vm.template[image_version].name
      node    = proxmox_virtual_environment_vm.template[image_version].node_name
      version = image_version
      vm_id   = proxmox_virtual_environment_vm.template[image_version].vm_id
    }
  }
}

output "image_versions" {
  description = "Immutable Proxmox template IDs by image version"

  value = {
    for image_version, template in proxmox_virtual_environment_vm.template :
    image_version => {
      name  = template.name
      node  = template.node_name
      vm_id = template.vm_id
    }
  }
}
