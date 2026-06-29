vms = {
  #   vm-test-debian = {
  #     vm_id = 251
  #     tags  = ["vm", "debian", "test"]
  #     image = "debian_13"
  #
  #     cores  = 1
  #     memory = 1024
  #
  #     disks = [
  #       { interface = "scsi0", size = 8 },
  #     ]
  #
  #     network_interfaces = [
  #       { bridge = "vmbr0", ipv4_address = "192.168.178.251/24", ipv4_gateway = "192.168.178.1" }
  #     ]
  #     nameservers = ["192.168.178.206"]
  #
  #     user     = "debian"
  #     ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  #
  #     qemu_agent_enabled            = true
  #     cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  #   }

  #   vm-test-ubuntu = {
  #     vm_id = 252
  #     tags  = ["vm", "ubuntu", "test"]
  #     image = "ubuntu_24_04"
  #
  #     cores  = 1
  #     memory = 1024
  #
  #     disks = [
  #       { interface = "scsi0", size = 8 },
  #     ]
  #
  #     network_interfaces = [
  #       { bridge = "vmbr0", ipv4_address = "192.168.178.252/24", ipv4_gateway = "192.168.178.1" }
  #     ]
  #     nameservers = ["192.168.178.206"]
  #
  #     user     = "ubuntu"
  #     ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  #
  #     qemu_agent_enabled            = true
  #     cloud_config_vendor_data_file = "local:snippets/cloud-config-vendor-qemu-guest-agent.yaml"
  #   }
}
