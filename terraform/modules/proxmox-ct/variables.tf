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

variable "disk_size" {
  type    = number
  default = 8
}

variable "datastore_id" {
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
