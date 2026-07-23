variable "artifact_dir" {
  type    = string
  default = "artifacts"
}

variable "cloud_init_dir" {
  type = string
}

variable "image_version" {
  type = string
}

variable "ssh_password" {
  type    = string
  default = "packer"
}
