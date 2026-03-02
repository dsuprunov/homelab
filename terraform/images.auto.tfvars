cloud_images = {
  ubuntu_24_04 = {
    content_type = "import"
    url          = "https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img"
    file_name    = "ubuntu-24.04-server-cloudimg-amd64.qcow2"
  }

  debian_13 = {
    content_type = "import"
    url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
    file_name    = "debian-13-genericcloud-amd64.qcow2"
  }
}
