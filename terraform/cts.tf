variable "cts" {
  type = map(object({
    ct_id = number

    node_name = optional(string, "pve")
    tags      = optional(list(string), [])

    os_template = string # "local:vztmpl/template.tar.zst"
    os_type     = optional(string, "unmanaged")

    nesting      = optional(bool, false)
    unprivileged = optional(bool, true)

    cpu_cores = optional(number, 1)
    memory    = optional(number, 512)
    swap      = optional(number, 0)
    disk_size = optional(number, 8)

    datastore_id = optional(string, "local-lvm")
    mount_points = optional(list(object({
      volume = string
      path   = string
    })), [])

    bridge   = optional(string, "vmbr0")
    firewall = optional(bool, true)

    ipv4_address = string                 # "192.168.178.209/24", "dhcp"
    ipv4_gateway = optional(string, null) # "192.168.178.1"
    nameservers  = optional(list(string), [])
    ssh_keys     = optional(list(string), [])

    started = optional(bool, true)
    on_boot = optional(bool, true)
  }))

  default = {}
}

module "proxmox_ct" {
  for_each = var.cts

  source = "./modules/proxmox-ct"

  providers = {
    proxmox = proxmox
  }

  name      = each.key
  node_name = each.value.node_name
  ct_id     = each.value.ct_id
  tags      = each.value.tags

  os_template  = each.value.os_template
  os_type      = each.value.os_type
  nesting      = each.value.nesting
  unprivileged = each.value.unprivileged

  cpu_cores = each.value.cpu_cores
  memory    = each.value.memory
  swap      = each.value.swap
  disk_size = each.value.disk_size

  datastore_id = each.value.datastore_id
  mount_points = each.value.mount_points

  bridge   = each.value.bridge
  firewall = each.value.firewall

  ipv4_address = each.value.ipv4_address
  ipv4_gateway = each.value.ipv4_gateway
  nameservers  = each.value.nameservers
  ssh_keys     = each.value.ssh_keys

  started = each.value.started
  on_boot = each.value.on_boot
}

output "cts" {
  description = "CTs: id, name, ip, tags"
  value = {
    for ct_name, m in module.proxmox_ct :
    ct_name => {
      id   = m.id
      name = m.name
      ip   = m.ip
      tags = join(", ", m.tags)
    }
  }
}
