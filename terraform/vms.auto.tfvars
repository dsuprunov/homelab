vms = {
  test-1 = {
    vm_id              = 224
    tags               = ["ubuntu", "k8s", "control"]
    cloud_image        = "ubuntu_24_04"
    qemu_agent_enabled = false

    cores  = 2
    memory = 2048
    disk   = 8

    ipv4_address = "192.168.178.224/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  }

  test-2 = {
    vm_id              = 225
    tags               = ["ubuntu", "k8s", "worker"]
    cloud_image        = "ubuntu_24_04"
    qemu_agent_enabled = false

    cores  = 2
    memory = 2048
    disk   = 8

    ipv4_address = "192.168.178.225/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  }

  test-3 = {
    vm_id       = 226
    tags        = ["ubuntu", "k8s", "worker"]
    cloud_image = "ubuntu_24_04"

    cores  = 1
    memory = 1024
    disk   = 8

    ipv4_address = "dhcp"
    nameservers  = ["192.168.178.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  }
}
