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
}
