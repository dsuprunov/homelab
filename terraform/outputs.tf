output "vms" {
  description = "VMs: id, name, ip, tags"
  value = {
    for vm_name, m in module.proxmox_vm :
    vm_name => {
      id   = m.id
      name = m.name
      ip   = m.ip
      tags = join(", ", m.tags)
    }
  }
}