output "vms" {
  value = {
    for k, vm in var.vms : k => {
      vmid        = vm.vmid
      name        = vm.name
      template    = vm.template
      target_node = vm.target_node
      state       = vm.state
      onboot      = vm.onboot
      memory      = vm.memory
      disk        = vm.disk
      cores       = vm.cores
      ipconfig    = vm.ipconfig
      nameserver  = vm.nameserver
      user        = vm.user
    }
  }
}
