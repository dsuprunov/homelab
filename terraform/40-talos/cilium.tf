locals {
  cilium_version      = "1.19.5"
  gateway_api_version = "1.4.1"

  cilium_values = {
    kubeProxyReplacement = true
    k8sServiceHost       = var.kubernetes_api_vip
    k8sServicePort       = 6443

    devices = var.talos_network_interface

    nodePort = {
      directRoutingDevice = var.talos_network_interface
    }

    ipam = {
      mode = "kubernetes"
    }

    securityContext = {
      capabilities = {
        ciliumAgent = [
          "CHOWN",
          "KILL",
          "NET_ADMIN",
          "NET_RAW",
          "IPC_LOCK",
          "SYS_ADMIN",
          "SYS_RESOURCE",
          "DAC_OVERRIDE",
          "FOWNER",
          "SETGID",
          "SETUID",
        ]

        cleanCiliumState = [
          "NET_ADMIN",
          "SYS_ADMIN",
          "SYS_RESOURCE",
        ]
      }
    }

    cgroup = {
      autoMount = {
        enabled = false
      }

      hostRoot = "/sys/fs/cgroup"
    }

    socketLB = {
      enabled           = true
      hostNamespaceOnly = true
    }

    cni = {
      exclusive = true
    }

    l2announcements = {
      enabled = true
    }

    k8sClientRateLimit = {
      qps   = 20
      burst = 40
    }

    envoy = {
      enabled = true
    }

    gatewayAPI = {
      enabled           = true
      enableAlpn        = true
      enableAppProtocol = true
    }

    debug = {
      enabled = false
    }
  }

  cilium_load_balancer_ip_pool_manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "cilium-vips"
    }
    spec = {
      blocks = [
        {
          start = var.cilium_load_balancer_ip_pool.start
          stop  = var.cilium_load_balancer_ip_pool.stop
        }
      ]
    }
  }

  cilium_l2_announcement_policy_manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumL2AnnouncementPolicy"
    metadata = {
      name = "l2-gateway-vip"
    }
    spec = {
      interfaces      = ["^${var.talos_network_interface}$"]
      loadBalancerIPs = true
    }
  }

  cilium_ingress_gateway_namespace_manifest = {
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = "cilium-ingress-gateway"
    }
  }

  cilium_ingress_gateway_manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "public"
      namespace = "cilium-ingress-gateway"
    }
    spec = {
      gatewayClassName = "cilium"
      addresses = [
        {
          type  = "IPAddress"
          value = var.cilium_ingress_gateway_ip
        }
      ]
      listeners = [
        {
          name     = "http-k8s-home-arpa"
          hostname = var.cilium_ingress_gateway_hostname
          port     = 80
          protocol = "HTTP"
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        }
      ]
    }
  }
}

data "http" "gateway_api_standard_install" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v${local.gateway_api_version}/standard-install.yaml"
}

data "helm_template" "cilium" {
  name         = "cilium"
  repository   = "oci://quay.io/cilium/charts"
  chart        = "cilium"
  version      = local.cilium_version
  namespace    = "kube-system"
  kube_version = trimprefix(var.kubernetes_version, "v")
  include_crds = true

  values = [
    yamlencode(local.cilium_values),
  ]
}
