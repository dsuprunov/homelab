locals {
  node_ipv4_addresses = {
    for vm_name, vm in var.vms :
    vm_name => split("/", vm.network_interfaces[0].ipv4_address)[0]
  }

  controlplane_nodes = {
    for vm_name, vm in var.vms :
    vm_name => vm if vm.role == "controlplane"
  }

  controlplane_ipv4_addresses = {
    for vm_name, vm in local.controlplane_nodes :
    vm_name => local.node_ipv4_addresses[vm_name]
  }

  bootstrap_node_name = sort(keys(local.controlplane_nodes))[0]
  bootstrap_node_ip   = local.node_ipv4_addresses[local.bootstrap_node_name]
  cluster_endpoint    = "https://${var.kubernetes_api_host}:6443"
}

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "node" {
  for_each = var.vms

  cluster_name       = var.cluster_name
  cluster_endpoint   = local.cluster_endpoint
  machine_type       = each.value.role
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname    = each.key
          nameservers = each.value.nameservers
          interfaces = [
            merge(
              {
                interface = var.talos_network_interface
                dhcp      = false
                addresses = [each.value.network_interfaces[0].ipv4_address]
                routes = [
                  {
                    network = "0.0.0.0/0"
                    gateway = each.value.network_interfaces[0].ipv4_gateway
                  }
                ]
              },
              each.value.role == "controlplane" ? {
                vip = {
                  ip = var.kubernetes_api_vip
                }
              } : {}
            )
          ]
        }

        features = {
          qemuGuestAgent = {
            enabled = true
          }
        }
      }

      cluster = {
        apiServer = {
          certSANs = concat(
            [var.kubernetes_api_host, var.kubernetes_api_vip],
            values(local.controlplane_ipv4_addresses),
          )
        }
      }
    }),
  ]
}

resource "talos_machine_configuration_apply" "node" {
  for_each = var.vms

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.node[each.key].machine_configuration
  node                        = local.node_ipv4_addresses[each.key]
  endpoint                    = local.node_ipv4_addresses[each.key]
  apply_mode                  = "auto"

  depends_on = [module.proxmox_vm]

  timeouts = {
    create = "20m"
    update = "20m"
  }
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_node_ip
  endpoint             = local.bootstrap_node_ip

  depends_on = [talos_machine_configuration_apply.node]

  timeouts = {
    create = "20m"
  }
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_node_ip
  endpoint             = local.bootstrap_node_ip

  depends_on = [talos_machine_bootstrap.this]

  timeouts = {
    create = "20m"
    update = "20m"
  }
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = values(local.node_ipv4_addresses)
  endpoints            = values(local.controlplane_ipv4_addresses)
}
