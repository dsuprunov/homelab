dns_a_records = {
  pve-01            = { addresses = ["192.168.178.200"] }
  vm-technitium-01  = { addresses = ["192.168.178.205"] }
  vm-vault-01       = { addresses = ["192.168.178.206"] }
  vm-k8s-api-lb-01  = { addresses = ["192.168.178.207"] }
  k8s-api           = { addresses = ["192.168.178.225"] }
  vm-k8s-control-01 = { addresses = ["192.168.178.226"] }
  vm-k8s-worker-01  = { addresses = ["192.168.178.230"] }
  vm-k8s-worker-02  = { addresses = ["192.168.178.231"] }
  vm-k8s-worker-03  = { addresses = ["192.168.178.232"] }
}

dns_cname_records = {
  vault = { cname = "vm-vault-01.home.arpa." }
}
