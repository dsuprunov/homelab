vms = {
  vm-coredns = {
    vm_id = 206
    tags  = ["vm", "debian", "coredns"]
    image = "debian_13"

    cores   = 1
    memory  = 1024
    balloon = 512

    disks = [
      { interface = "scsi0", size = 8 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.206/24", ipv4_gateway = "192.168.178.1" },
    ]
    nameservers = ["8.8.8.8", "1.1.1.1"]

    user     = "debian"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  #   vm-garage-01 = {
  #     vm_id = 207
  #     tags  = ["vm", "debian", "garage"]
  #     image = "debian_13"
  #
  #     cores  = 1
  #     memory = 1024
  #     balloon = 512
  #
  #     disks = [
  #       { interface = "scsi0", size = 8 },
  #       { interface = "scsi1", size = 32 },
  #     ]
  #
  #     network_interfaces = [
  #       { bridge = "vmbr0", ipv4_address = "192.168.178.207/24", ipv4_gateway = "192.168.178.1" },
  #     ]
  #     nameservers = ["192.168.178.206"]
  #
  #     user     = "debian"
  #     ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  #
  #     qemu_agent_enabled            = true
  #     cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  #   }
  #
  #   vm-vault-01 = {
  #     vm_id = 208
  #     tags  = ["vm", "debian", "vault"]
  #     image = "debian_13"
  #
  #     cores  = 1
  #     memory = 1024
  #
  #     disks = [
  #       { interface = "scsi0", size = 8 }
  #     ]
  #
  #     network_interfaces = [
  #       { bridge = "vmbr0", ipv4_address = "192.168.178.208/24", ipv4_gateway = "192.168.178.1" },
  #     ]
  #     nameservers = ["192.168.178.206"]
  #
  #     user     = "debian"
  #     ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  #
  #     qemu_agent_enabled            = true
  #     cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  #   }

  vm-k8s-control-01 = {
    vm_id = 231
    tags  = ["vm", "ubuntu", "k8s", "control"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.231/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.206"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-worker-01 = {
    vm_id = 236
    tags  = ["vm", "ubuntu", "k8s", "worker"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
      { interface = "scsi1", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.236/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.206"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-worker-02 = {
    vm_id = 237
    tags  = ["vm", "ubuntu", "k8s", "worker"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
      { interface = "scsi1", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.237/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.206"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-worker-03 = {
    vm_id = 238
    tags  = ["vm", "ubuntu", "k8s", "worker"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
      { interface = "scsi1", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.238/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.206"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-test-debian = {
    vm_id = 251
    tags  = ["vm", "debian", "test"]
    image = "debian_13"

    cores  = 1
    memory = 1024

    disks = [
      { interface = "scsi0", size = 8 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.251/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.206"]

    user     = "debian"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-test-ubuntu = {
    vm_id = 252
    tags  = ["vm", "ubuntu", "test"]
    image = "ubuntu_24_04"

    cores  = 1
    memory = 1024

    disks = [
      { interface = "scsi0", size = 8 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.252/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.206"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }
}
