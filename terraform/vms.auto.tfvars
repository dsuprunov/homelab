vms = {
  ubuntu-test-221 = {
    vm_id = 221
    tags  = ["ubuntu", "test", "ip"]
    image = "ubuntu_24_04"

    cores  = 1
    memory = 1024

    disks = [
      { interface = "scsi0", size = 8 },
      { interface = "scsi1", size = 8 },
    ]

    ipv4_address = "192.168.178.221/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  debian-test-231 = {
    vm_id = 231
    tags  = ["ubuntu", "test", "ip"]
    image = "debian_13"

    cores  = 1
    memory = 1024

    disks = [
      { interface = "scsi0", size = 8 },
      { interface = "scsi1", size = 8 },
    ]

    ipv4_address = "192.168.178.231/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  # test-225 = {
  #   vm_id = 225
  #   tags  = ["ubuntu", "test", "ip"]
  #   image = "ubuntu_24_04"
  #
  #   cores  = 1
  #   memory = 1024
  #
  #   disks = [
  #     { interface = "scsi0", size = 8 },
  #     { interface = "scsi1", size = 16 },
  #   ]
  #
  #   ipv4_address = "192.168.178.225/24"
  #   ipv4_gateway = "192.168.178.1"
  #   nameservers  = ["192.168.178.1"]
  #
  #   user     = "ubuntu"
  #   ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  #
  #   # qemu_agent_enabled = false
  # }

  # test-226 = {
  #   vm_id = 226
  #   tags  = ["ubuntu", "test"]
  #   image = "ubuntu_24_04"
  #
  #   cores  = 1
  #   memory = 1024
  #
  #   disks = [
  #     { interface = "scsi0", size = 8 },
  #   ]
  #
  #   ipv4_address = "192.168.178.226/24"
  #   ipv4_gateway = "192.168.178.1"
  #   nameservers  = ["192.168.178.1"]
  #
  #   user     = "ubuntu"
  #   ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  #
  #   # qemu_agent_enabled = false
  # }

  # test-227 = {
  #   vm_id = 227
  #   tags  = ["ubuntu", "test", "dhcp"]
  #   image = "ubuntu_24_04"
  #
  #   cores  = 1
  #   memory = 1024
  #
  #   disks = [
  #     { interface = "scsi0", size = 8 },
  #   ]
  #
  #   ipv4_address = "dhcp"
  #
  #   user     = "ubuntu"
  #   ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  #
  #   qemu_agent_enabled            = true
  #   cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  # }
}
