vms = {
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

    vm-k8s-control-02 = {
      vm_id = 232
      tags  = ["vm", "ubuntu", "k8s", "control"]
      image = "ubuntu_24_04"

      cores  = 2
      memory = 4096

      disks = [
        { interface = "scsi0", size = 32 },
      ]

      network_interfaces = [
        { bridge = "vmbr0", ipv4_address = "192.168.178.232/24", ipv4_gateway = "192.168.178.1" }
      ]
      nameservers = ["192.168.178.206"]

      user     = "ubuntu"
      ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]

      qemu_agent_enabled            = true
      cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
    }

    vm-k8s-control-03 = {
      vm_id = 233
      tags  = ["vm", "ubuntu", "k8s", "control"]
      image = "ubuntu_24_04"

      cores  = 2
      memory = 4096

      disks = [
        { interface = "scsi0", size = 32 },
      ]

      network_interfaces = [
        { bridge = "vmbr0", ipv4_address = "192.168.178.233/24", ipv4_gateway = "192.168.178.1" }
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
}
