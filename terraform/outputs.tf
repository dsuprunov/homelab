output "vm" {
  value = {
    for k, vm in var.vm : k => {
      vmid = vm.vmid
      # template = vm.template
      # target_node = vm.target_node
      # state       = vm.state
      # onboot      = vm.onboot
      # memory     = vm.memory
      # disk       = vm.disk
      # cores      = vm.cores
      ipconfig = vm.ipconfig
      # nameserver = try(vm.nameserver, null)
      user = vm.user
    }
  }
}