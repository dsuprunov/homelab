variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

variable "dns_update_server" {
  type = string
}

variable "dns_update_port" {
  type    = number
  default = 53
}

variable "dns_update_key_name" {
  type = string
}

variable "dns_update_key_secret" {
  type      = string
  sensitive = true
}

variable "dns_update_key_algorithm" {
  type    = string
  default = "hmac-sha256"
}
