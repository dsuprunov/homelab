output "vms" {
  description = "VMs: id, name, ips, tags"

  value = {
    for vm_name, vm in module.proxmox_vm :
    vm_name => {
      id   = vm.id
      name = vm.name
      ips  = vm.ips
      tags = join(", ", vm.tags)
    }
  }
}

output "talos_images" {
  description = "Talos image factory file IDs by image key"

  value = {
    for image_name, image in proxmox_download_file.talos_image :
    image_name => image.id
  }
}

output "kubeconfig" {
  description = "Talos cluster kubeconfig"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "talosconfig" {
  description = "Talos client configuration"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}
