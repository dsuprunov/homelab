vms = {
  vm-pihole = {
    vm_id = 201
    tags  = ["debian", "pihole"]
    image = "debian_13"

    cores  = 1
    memory = 1024

    disks = [
      { interface = "scsi0", size = 8 },
    ]

    ipv4_address = "192.168.178.201/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.1"]

    user     = "debian"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-control-01 = {
    vm_id = 210
    tags  = ["ubuntu", "k8s", "control"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 16 },
    ]

    ipv4_address = "192.168.178.210/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.201", "192.168.178.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-worker-01 = {
    vm_id = 220
    tags  = ["ubuntu", "k8s", "worker"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 16 },
      { interface = "scsi1", size = 32 },
    ]

    ipv4_address = "192.168.178.220/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.201", "192.168.178.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-worker-02 = {
    vm_id = 221
    tags  = ["ubuntu", "k8s", "worker"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 16 },
      { interface = "scsi1", size = 32 },
    ]

    ipv4_address = "192.168.178.221/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.201", "192.168.178.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-worker-03 = {
    vm_id = 222
    tags  = ["ubuntu", "k8s", "worker"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 16 },
      { interface = "scsi1", size = 32 },
    ]

    ipv4_address = "192.168.178.222/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.201", "192.168.178.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }


  # debian-test-231 = {
  #   vm_id = 231
  #   tags  = ["debian", "test", "ip"]
  #   image = "debian_13"
  #
  #   cores  = 1
  #   memory = 1024
  #
  #   disks = [
  #     { interface = "scsi0", size = 8 },
  #     { interface = "scsi1", size = 8 },
  #   ]
  #
  #   ipv4_address = "192.168.178.231/24"
  #   ipv4_gateway = "192.168.178.1"
  #   nameservers  = ["192.168.178.1"]
  #
  #   user     = "ubuntu"
  #   ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  #
  #   qemu_agent_enabled            = true
  #   cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  # }

  # ubunt-test-232 = {
  #   vm_id = 232
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
  #   ipv4_address = "192.168.178.232/24"
  #   ipv4_gateway = "192.168.178.1"
  #   nameservers  = ["192.168.178.1"]
  #
  #   user     = "ubuntu"
  #   ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  #
  #   # qemu_agent_enabled = false
  # }

  # ubuntu-test-233 = {
  #   vm_id = 233
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
