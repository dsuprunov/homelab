vms = {
  vm-k8s-control-01 = {
    vm_id = 231
    role  = "controlplane"
    tags  = ["vm", "talos", "k8s", "control"]
    image = "talos_control"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.231/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.206"]
  }

  vm-k8s-control-02 = {
    vm_id = 232
    role  = "controlplane"
    tags  = ["vm", "talos", "k8s", "control"]
    image = "talos_control"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.232/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.206"]
  }

  vm-k8s-control-03 = {
    vm_id = 233
    role  = "controlplane"
    tags  = ["vm", "talos", "k8s", "control"]
    image = "talos_control"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.233/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.206"]
  }

  vm-k8s-worker-01 = {
    vm_id = 236
    role  = "worker"
    tags  = ["vm", "talos", "k8s", "worker"]
    image = "talos_worker"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.236/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.206"]
  }

  vm-k8s-worker-02 = {
    vm_id = 237
    role  = "worker"
    tags  = ["vm", "talos", "k8s", "worker"]
    image = "talos_worker"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.237/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.206"]
  }

  vm-k8s-worker-03 = {
    vm_id = 238
    role  = "worker"
    tags  = ["vm", "talos", "k8s", "worker"]
    image = "talos_worker"

    cores  = 2
    memory = 4096

    disks = [
      { interface = "scsi0", size = 32 },
    ]

    network_interfaces = [
      { bridge = "vmbr0", ipv4_address = "192.168.178.238/24", ipv4_gateway = "192.168.178.1" }
    ]
    nameservers = ["192.168.178.206"]
  }
}
