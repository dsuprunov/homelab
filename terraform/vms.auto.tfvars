vms = {
  vm-router = {
    vm_id = 101
    tags  = ["vm", "debian", "router", "dns"]
    image = "debian_13"

    cores  = 1
    memory = 1024

    disks = [
      { interface = "scsi0", size = 8 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.200/24", ipv4_gateway = "192.168.178.1" },
      { bridge = "vmbr1", ipv4_address = "10.10.0.1/24" }
    ]
    nameservers = ["8.8.8.8", "1.1.1.1"]

    user     = "debian"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-control-01 = {
    vm_id = 10121
    tags  = ["vm", "ubuntu", "k8s", "control"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 16 },
    ]

    network_interfaces = [
      { bridge = "vmbr1", ipv4_address = "10.10.0.121/24", ipv4_gateway = "10.10.0.1" }
    ]
    nameservers  = ["10.10.0.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-worker-01 = {
    vm_id = 10151
    tags  = ["vm", "ubuntu", "k8s", "worker"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
      { interface = "scsi1", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr1", ipv4_address = "10.10.0.151/24", ipv4_gateway = "10.10.0.1" }
    ]
    nameservers  = ["10.10.0.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-worker-02 = {
    vm_id = 10152
    tags  = ["vm", "ubuntu", "k8s", "worker"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
      { interface = "scsi1", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr1", ipv4_address = "10.10.0.152/24", ipv4_gateway = "10.10.0.1" }
    ]
    nameservers  = ["10.10.0.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-worker-03 = {
    vm_id = 10153
    tags  = ["vm", "ubuntu", "k8s", "worker"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
      { interface = "scsi1", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr1", ipv4_address = "10.10.0.153/24", ipv4_gateway = "10.10.0.1" }
    ]
    nameservers  = ["10.10.0.1"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-test = {
    vm_id = 10251
    tags  = ["vm", "debian", "test"]
    image = "debian_13"

    cores  = 1
    memory = 1024

    disks = [
      { interface = "scsi0", size = 8 },
    ]

    network_interfaces = [
      { bridge = "vmbr1", ipv4_address = "10.10.0.251/24", ipv4_gateway = "10.10.0.1"}
    ]
    nameservers = ["10.10.0.1"]

    user     = "debian"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }
}
