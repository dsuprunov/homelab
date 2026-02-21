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
  default = false
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

variable "virtiofs" {
  type = list(object({
    mapping      = string
    cache        = optional(string, "auto")
    direct_io    = optional(bool, null)
    expose_acl   = optional(bool, null)
    expose_xattr = optional(bool, null)
  }))
  default = []
}

variable "datastore_id" {
  type    = string
  default = "local-lvm"
}

variable "cloudinit_datastore_id" {
  type    = string
  default = "local-lvm"
}

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "firewall" {
  type    = bool
  default = true
}

variable "ipv4_address" {
  type = string
}

variable "ipv4_gateway" {
  type    = string
  default = null
}

variable "nameservers" {
  type    = list(string)
  default = []
}

variable "user" {
  type    = string
  default = "ubuntu"
}

variable "ssh_keys" {
  type    = list(string)
  default = []
}

variable "import_from" {
  type = string
}

variable "cloud_config_vendor_data_file" {
  type    = string
  default = null
}
