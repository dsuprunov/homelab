variable "proxmox" {
  type = object({
    endpoint  = string
    api_token = string
  })
  sensitive = true
}

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
      ipv4_address = string                 # "192.168.178.231/24", "dhcp"
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
  }))

  default = {}
}
