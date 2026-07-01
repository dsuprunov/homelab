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
    role      = string
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

    started = optional(bool, true)
    on_boot = optional(bool, true)

    qemu_agent_enabled = optional(bool, true)
    qemu_agent_timeout = optional(string, null)
  }))

  default = {}

  validation {
    condition     = alltrue([for _, vm in var.vms : contains(["controlplane", "worker"], vm.role)])
    error_message = "Each VM role must be either controlplane or worker."
  }
}

variable "cluster_name" {
  type    = string
  default = "homelab"
}

variable "talos_version" {
  type    = string
  default = "v1.13.5"
}

variable "talos_images" {
  type = map(object({
    platform   = optional(string, "nocloud")
    extensions = optional(list(string), [])

    datastore_id = optional(string, "local")
    node_name    = optional(string, "pve-01")
  }))

  default = {}
}

variable "kubernetes_version" {
  type    = string
  default = "v1.36.2"
}

variable "kubernetes_api_host" {
  type    = string
  default = "k8s-api.home.arpa"
}

variable "kubernetes_api_vip" {
  type    = string
  default = "192.168.178.230"
}

variable "talos_network_interface" {
  type    = string
  default = "eth0"
}
