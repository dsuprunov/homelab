cts = {
  ct-coredns = {
    ct_id = 205
    tags  = ["ct", "coredns"]

    os_template = "local:vztmpl/coredns-latest.tar"
    os_type     = "alpine"

    cpu_cores = 1
    memory    = 128
    disk_size = 1

    ipv4_address = "192.168.178.101/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.1"]

    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  }
}
