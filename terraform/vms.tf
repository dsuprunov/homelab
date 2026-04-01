variable "vms" {
  type = map(object({
    vm_id = number

    node_name = optional(string, "pve-01")
    tags      = optional(list(string), [])

    image = string

    cores   = optional(number, 1)
    sockets = optional(number, 1)
    memory  = optional(number, 1024)
    balloon = optional(number, 0)

    disks = list(object({
      interface    = string
      size         = number
      datastore_id = optional(string, null)
    }))

    virtiofs = optional(list(object({
      mapping = string

      cache        = optional(string, "auto")
      direct_io    = optional(bool, null)
      expose_acl   = optional(bool, null)
      expose_xattr = optional(bool, null)
    })), [])

    datastore_id           = optional(string, "local-lvm")
    cloudinit_datastore_id = optional(string, "local-lvm")

    network_interfaces = list(object({
      bridge       = string
      ipv4_address = string                 # "192.168.178.224/24", "dhcp"
      ipv4_gateway = optional(string, null) # "192.168.178.1"
      firewall     = optional(bool, true)
      model        = optional(string, "virtio")
    }))

    nameservers = optional(list(string), [])
    user        = optional(string, "root")
    ssh_keys    = list(string)

    started = optional(bool, true)
    on_boot = optional(bool, true)

    qemu_agent_enabled = optional(bool, false)
    qemu_agent_timeout = optional(string, null)

    cloud_config_vendor_data_file = optional(string, null)
  }))

  default = {}
}

module "proxmox_vm" {
  for_each = var.vms

  source = "./modules/proxmox-vm"

  providers = {
    proxmox = proxmox
  }

  name      = each.key
  node_name = each.value.node_name
  vm_id     = each.value.vm_id
  tags      = each.value.tags

  cores   = each.value.cores
  sockets = each.value.sockets
  memory  = each.value.memory
  balloon = each.value.balloon

  disks    = each.value.disks
  virtiofs = each.value.virtiofs

  datastore_id           = each.value.datastore_id
  cloudinit_datastore_id = each.value.cloudinit_datastore_id

  network_interfaces = each.value.network_interfaces
  nameservers        = each.value.nameservers
  user               = each.value.user
  ssh_keys           = each.value.ssh_keys

  import_from = proxmox_virtual_environment_download_file.image[each.value.image].id

  started = each.value.started
  on_boot = each.value.on_boot

  qemu_agent_enabled = each.value.qemu_agent_enabled
  qemu_agent_timeout = each.value.qemu_agent_timeout

  cloud_config_vendor_data_file = each.value.cloud_config_vendor_data_file
}

output "vms" {
  description = "VMs: id, name, ips, tags"
  value = {
    for vm_name, m in module.proxmox_vm :
    vm_name => {
      id   = m.id
      name = m.name
      ips  = m.ips
      tags = join(", ", m.tags)
    }
  }
}
