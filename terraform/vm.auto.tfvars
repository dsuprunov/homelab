vm = {
  test-vm-1 = {
    vmid        = 221
    name        = "test-vm-1"
    template    = "ubuntu-24.04-ci"
    target_node = "pve"
    state       = "running"
    onboot      = true
    memory      = 1024
    disk        = "8G"
    cores       = 1
    ipconfig    = "ip=192.168.178.221/24,gw=192.168.178.1"
    nameserver  = "192.168.178.1"
    user        = "ubuntu"
    ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  }

  test-vm-2 = {
    vmid        = 222
    name        = "test-vm-2"
    template    = "debian-13-ci"
    target_node = "pve"
    state       = "running"
    onboot      = true
    memory      = 1024
    disk        = "8G"
    cores       = 1
    ipconfig    = "ip=192.168.178.222/24,gw=192.168.178.1"
    nameserver  = "192.168.178.1"
    user        = "debian"
    ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"
  }
}
