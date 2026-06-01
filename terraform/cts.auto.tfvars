cts = {
  #   ct-test-252 = {
  #     ct_id = 252
  #     tags  = ["ct", "test"]
  #
  #     os_template = "local:vztmpl/dsuprunov-demo-website-latest.tar"
  #     os_type     = "alpine"
  #
  #     cpu_cores = 1
  #     memory    = 128
  #     disk = {
  #       size = 1
  #     }
  #
  #     network_interfaces = [
  #       { bridge = "vmbr0", ipv4_address = "192.168.178.252/24", ipv4_gateway = "192.168.178.1" },
  #     ]
  #     nameservers = ["192.168.178.206"]
  #   }
}
