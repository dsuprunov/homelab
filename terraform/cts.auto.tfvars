cts = {
  ct-dummy-portal = {
    ct_id = 209
    tags  = ["ct", "dummy-portal", "test"]

    template_file_id = "local:vztmpl/dsuprunov-dummy-portal-latest.tar"

    cpu_cores = 1
    memory    = 512
    disk_size = 4

    ipv4_address = "192.168.178.209/24"
    ipv4_gateway = "192.168.178.1"
    nameservers  = ["192.168.178.1"]

    ssh_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMR9r620XCqAjcmtgnFjVZe5jhyR/hvv6cFQzPaEVK9"]
  }
}
