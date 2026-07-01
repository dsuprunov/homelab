variable "name" {
  type = string
}

variable "node_name" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "started" {
  type    = bool
  default = true
}

variable "on_boot" {
  type    = bool
  default = true
}

variable "qemu_agent_enabled" {
  type    = bool
  default = true
}

variable "qemu_agent_timeout" {
  type    = string
  default = null
}

variable "cores" {
  type    = number
  default = 1
}

variable "sockets" {
  type    = number
  default = 1
}

variable "memory" {
  type    = number
  default = 1024
}

variable "balloon" {
  type    = number
  default = 0
}

variable "disks" {
  type = list(object({
    interface    = string
    size         = number
    datastore_id = optional(string, null)
  }))
}

variable "datastore_id" {
  type    = string
  default = "local-lvm"
}

variable "cloudinit_datastore_id" {
  type    = string
  default = "local-lvm"
}

variable "network_interfaces" {
  type = list(object({
    bridge       = string
    ipv4_address = string
    ipv4_gateway = optional(string, null)
    firewall     = optional(bool, true)
    model        = optional(string, "virtio")
  }))
}

variable "nameservers" {
  type    = list(string)
  default = []
}

variable "image_file_id" {
  type = string
}
