vms = {
  vm-technitium-01 = {
    vm_id = 205
    tags  = ["vm", "debian", "technitium"]
    image = "debian_13"

    cores  = 1
    memory = 1024

    disks = [
      { interface = "scsi0", size = 8 },
    ]

    virtiofs = [
      { mapping = "vm-technitium-01", cache = "auto" },
    ]

    ipv4_address = "192.168.178.205/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["8.8.8.8", "8.8.4.4"]

    user     = "debian"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-vault-01 = {
    vm_id = 206
    tags  = ["vm", "debian", "vault"]
    image = "debian_13"

    cores  = 1
    memory = 2048

    disks = [
      { interface = "scsi0", size = 8 },
    ]

    virtiofs = [
      { mapping = "vm-vault-01", cache = "auto" },
    ]

    ipv4_address = "192.168.178.206/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.205", "8.8.8.8"]

    user     = "debian"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-api-lb-01 = {
    vm_id = 207
    tags  = ["vm", "debian", "k8s", "api-lb"]
    image = "debian_13"

    cores  = 1
    memory = 1024

    disks = [
      { interface = "scsi0", size = 8 },
    ]

    ipv4_address = "192.168.178.207/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.205", "8.8.8.8"]

    user     = "debian"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  # vm-k8s-api-lb-02 = {
  #   vm_id = 208
  #   tags  = ["vm", "ubuntu", "k8s", "api-lb"]
  #   image = "debian"
  #
  #   cores  = 1
  #   memory = 1024
  #
  #   disks = [
  #     { interface = "scsi0", size = 8 },
  #   ]
  #
  #   ipv4_address = "192.168.178.208/24"
  #   ipv4_gateway = "192.168.178.1"
  #   nameservers  = ["192.168.178.205", "8.8.8.8"]
  #
  #   user     = "debian"
  #   ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  #
  #   qemu_agent_enabled            = true
  #   cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  # }

  vm-k8s-control-01 = {
    vm_id = 226
    tags  = ["vm", "ubuntu", "k8s", "control"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 16 },
    ]

    ipv4_address = "192.168.178.226/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.205", "8.8.8.8"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-worker-01 = {
    vm_id = 230
    tags  = ["vm", "ubuntu", "k8s", "worker"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
      { interface = "scsi1", size = 32 },
    ]

    ipv4_address = "192.168.178.230/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.205", "8.8.8.8"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-worker-02 = {
    vm_id = 231
    tags  = ["vm", "ubuntu", "k8s", "worker"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
      { interface = "scsi1", size = 32 },
    ]

    ipv4_address = "192.168.178.231/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.205", "8.8.8.8"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }

  vm-k8s-worker-03 = {
    vm_id = 232
    tags  = ["vm", "ubuntu", "k8s", "worker"]
    image = "ubuntu_24_04"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
      { interface = "scsi1", size = 32 },
    ]

    ipv4_address = "192.168.178.232/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.205", "8.8.8.8"]

    user     = "ubuntu"
    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

    qemu_agent_enabled            = true
    cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  }


  # debian-test-231 = {
  #   vm_id = 231
  #   tags  = ["vm", "debian", "test", "ip"]
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
  #   tags  = ["vm", "ubuntu", "test"]
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
  #   tags  = ["vm", "ubuntu", "test", "dhcp"]
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
