locals {
  nodes = {
    "vm-k8s-control-01" = {
      role         = "controlplane"
      vm_id        = 231
      proxmox_node = "pve-01"
      cores        = 2
      memory       = 4096

      network_interface = { bridge = "vmbr0", interface = "eth0", ipv4_address = "192.168.178.231/24", ipv4_gateway = "192.168.178.1" }

      disks = [
        { interface = "scsi0", size = 32 },
      ]
    }
    "vm-k8s-control-02" = {
      role         = "controlplane"
      vm_id        = 232
      proxmox_node = "pve-01"
      cores        = 2
      memory       = 4096

      network_interface = { bridge = "vmbr0", interface = "eth0", ipv4_address = "192.168.178.232/24", ipv4_gateway = "192.168.178.1" }

      disks = [
        { interface = "scsi0", size = 32 },
      ]
    }
    "vm-k8s-control-03" = {
      role         = "controlplane"
      vm_id        = 233
      proxmox_node = "pve-01"
      cores        = 2
      memory       = 4096

      network_interface = { bridge = "vmbr0", interface = "eth0", ipv4_address = "192.168.178.233/24", ipv4_gateway = "192.168.178.1" }

      disks = [
        { interface = "scsi0", size = 32 },
      ]
    }
    "vm-k8s-worker-01" = {
      role         = "worker"
      vm_id        = 236
      proxmox_node = "pve-01"
      cores        = 2
      memory       = 6144

      network_interface = { bridge = "vmbr0", interface = "eth0", ipv4_address = "192.168.178.236/24", ipv4_gateway = "192.168.178.1" }

      disks = [
        { interface = "scsi0", size = 32 },
      ]
    }
    "vm-k8s-worker-02" = {
      role         = "worker"
      vm_id        = 237
      proxmox_node = "pve-01"
      cores        = 2
      memory       = 6144

      network_interface = { bridge = "vmbr0", interface = "eth0", ipv4_address = "192.168.178.237/24", ipv4_gateway = "192.168.178.1" }

      disks = [
        { interface = "scsi0", size = 32 },
      ]
    }
    "vm-k8s-worker-03" = {
      role         = "worker"
      vm_id        = 238
      proxmox_node = "pve-01"
      cores        = 2
      memory       = 6144

      network_interface = { bridge = "vmbr0", interface = "eth0", ipv4_address = "192.168.178.238/24", ipv4_gateway = "192.168.178.1" }

      disks = [
        { interface = "scsi0", size = 32 },
      ]
    }
  }

  control_nodes = {
    for name, node in local.nodes :
    name => node
    if node.role == "controlplane"
  }

  worker_nodes = {
    for name, node in local.nodes :
    name => node
    if node.role == "worker"
  }

  bootstrap_node = keys(local.control_nodes)[0]

  node_static_ipv4 = {
    for name, node in local.nodes :
    name => split("/", node.network_interface.ipv4_address)[0]
  }

  node_maintenance_ipv4 = {
    for name, vm in proxmox_virtual_environment_vm.talos :
    name => contains(flatten([
      for index, mac_address in vm.mac_addresses : [
        for address in vm.ipv4_addresses[index] :
        address
        if lower(mac_address) == lower(vm.network_device[0].mac_address)
      ]
      ]), local.node_static_ipv4[name]) ? local.node_static_ipv4[name] : one(flatten([
      for index, mac_address in vm.mac_addresses : [
        for address in vm.ipv4_addresses[index] :
        address
        if lower(mac_address) == lower(vm.network_device[0].mac_address)
      ]
    ]))
  }

  control_static_ipv4 = [
    for name in keys(local.control_nodes) :
    local.node_static_ipv4[name]
  ]

  worker_static_ipv4 = [
    for name in keys(local.worker_nodes) :
    local.node_static_ipv4[name]
  ]
}
