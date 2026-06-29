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
