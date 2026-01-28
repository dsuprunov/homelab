variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

variable "cloud_images" {
  type = map(object({
    content_type = string
    datastore_id = optional(string, "local")
    file_name    = string
    node_name    = optional(string, "pve")
    url          = string
  }))

  default = {
    ubuntu_24_04 = {
      content_type = "import"
      url          = "https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img"
      file_name    = "ubuntu-24.04-server-cloudimg-amd64.qcow2"
    }

    # debian_13 = {
    #   content_type = "import"
    #   url       = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
    #   file_name = "debian-13-genericcloud-amd64.qcow2"
    # }
  }
}

variable "vms" {
  type = map(object({
    vm_id = number

    node_name = optional(string, "pve")
    tags      = optional(list(string), [])

    image = string

    qemu_agent_enabled = optional(bool, false)
    qemu_agent_timeout = optional(string, null)

    cores   = optional(number, 1)
    sockets = optional(number, 1)
    memory  = optional(number, 1024)
    balloon = optional(number, 0)

    disk                   = optional(number, 8)
    datastore_id           = optional(string, "local-lvm")
    cloudinit_datastore_id = optional(string, "local-lvm")

    bridge   = optional(string, "vmbr0")
    firewall = optional(bool, true)

    ipv4_address = string                 # "192.168.178.224/24", "dhcp"
    ipv4_gateway = optional(string, null) # "192.168.178.1"
    nameservers  = optional(list(string), [])
    user         = optional(string, "root")
    ssh_keys     = list(string)

    started = optional(bool, true)
    on_boot = optional(bool, true)
  }))
}
