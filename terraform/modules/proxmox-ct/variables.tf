variable "name" {
  type = string
}

variable "node_name" {
  type = string
}

variable "ct_id" {
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

variable "nesting" {
  type    = bool
  default = false
}

variable "unprivileged" {
  type    = bool
  default = true
}

variable "cpu_cores" {
  type    = number
  default = 1
}

variable "memory" {
  type    = number
  default = 512
}

variable "swap" {
  type    = number
  default = 0
}

variable "disk" {
  type = object({
    size         = optional(number, 8)
    datastore_id = optional(string, "local-lvm")
  })
}

variable "network_interfaces" {
  type = list(object({
    bridge       = string
    ipv4_address = string
    ipv4_gateway = optional(string, null)
    firewall     = optional(bool, true)
  }))
}

variable "nameservers" {
  type    = list(string)
  default = []
}

variable "ssh_keys" {
  type    = list(string)
  default = []
}

variable "os_template" {
  type = string
}

variable "os_type" {
  type    = string
  default = "unmanaged"
}

variable "mount_points" {
  type = list(object({
    volume = string
    path   = string
  }))
  default = []
}
