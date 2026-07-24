resource "talos_machine_secrets" "this" {
  talos_version = local.cluster.talos_version
}

data "talos_machine_configuration" "this" {
  for_each = toset(["controlplane", "worker"])

  cluster_name       = local.cluster.name
  cluster_endpoint   = "https://${local.cluster.api_fqdn}:${local.cluster.api_port}"
  machine_type       = each.key
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = local.cluster.talos_version
  kubernetes_version = local.cluster.kubernetes_version

  config_patches = [
    yamlencode({
      cluster = {
        apiServer = {
          certSANs = [
            local.cluster.api_vip,
            local.cluster.api_fqdn,
          ]
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "this" {
  for_each = local.nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.value.role].machine_configuration
  node                        = local.node_maintenance_ipv4[each.key]
  endpoint                    = local.node_maintenance_ipv4[each.key]
  apply_mode                  = "auto"

  config_patches = concat(
    [
      yamlencode({
        machine = {
          install = {
            disk  = local.cluster.install_disk
            image = local.cluster.install_image
          }
        }
      }),
      yamlencode({
        apiVersion = "v1alpha1"
        kind       = "LinkConfig"
        name       = each.value.network_interface.interface
        up         = true
        addresses = [
          {
            address = each.value.network_interface.ipv4_address
          }
        ]
        routes = [
          {
            gateway = each.value.network_interface.ipv4_gateway
          }
        ]
      }),
      yamlencode({
        apiVersion = "v1alpha1"
        kind       = "HostnameConfig"
        hostname   = each.key
        auto       = "off"
      }),
      yamlencode({
        apiVersion = "v1alpha1"
        kind       = "ResolverConfig"
        nameservers = [
          for nameserver in local.cluster.nameservers : {
            address = nameserver
          }
        ]
      }),
    ],
    each.value.role == "controlplane" ? [
      yamlencode({
        apiVersion = "v1alpha1"
        kind       = "Layer2VIPConfig"
        name       = local.cluster.api_vip
        link       = each.value.network_interface.interface
      })
    ] : []
  )

  timeouts = {
    create = "15m"
    update = "15m"
  }

  lifecycle {
    ignore_changes = [
      endpoint,
      node,
    ]
  }
}

data "talos_client_configuration" "this" {
  cluster_name         = local.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.control_static_ipv4
  nodes                = concat(local.control_static_ipv4, local.worker_static_ipv4)
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this,
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.node_static_ipv4[local.bootstrap_node]
  endpoint             = local.node_static_ipv4[local.bootstrap_node]

  timeouts = {
    create = "15m"
  }
}

data "talos_cluster_health" "this" {
  depends_on = [
    talos_machine_bootstrap.this,
  ]

  client_configuration   = talos_machine_secrets.this.client_configuration
  endpoints              = local.control_static_ipv4
  control_plane_nodes    = local.control_static_ipv4
  worker_nodes           = local.worker_static_ipv4
  skip_kubernetes_checks = true

  timeouts = {
    read = "15m"
  }
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    data.talos_cluster_health.this,
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.node_static_ipv4[local.bootstrap_node]
  endpoint             = local.node_static_ipv4[local.bootstrap_node]

  timeouts = {
    create = "5m"
    update = "5m"
  }
}
