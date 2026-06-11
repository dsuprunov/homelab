# Infrastructure Overview

## Network

| Pool                   | Description                  | Adwertised By |
|------------------------|------------------------------|---------------|
| `192.168.178.201-205`  | Proxmox nodes                |               |
| `192.168.178.206-229`  | Virtual machines             |               |
| `192.168.178.230`      | Kubernetes API VIP           | `kube-vip`    |
| `192.168.178.231-235`  | Kubernetes Control Planes    |               |
| `192.168.178.236-245`  | Kubernetes Workers           |               |
| `192.168.178.246-250`  | Kubernetes LoadBalancer VIPs | `cilium`      |

## Hosts

| Host                          | Address           |    CPU |  RAM | Disk 0 | Disk 1 | Alias             |
|-------------------------------|-------------------|-------:|-----:|-------:|-------:|-------------------|
| `vm-coredns.home.arpa`        | `192.168.178.206` | 1 vCPU | 1 GB |   8 GB |        | `ns.home.arpa`    |
| `vm-garage-01.home.arpa`      | `192.168.178.207` | 1 vCPU | 1 GB |   8 GB |  32 GB | `s3.home.arpa`    |
| `vm-vault-01.home.arpa`       | `192.168.178.208` | 1 vCPU | 1 GB |   8 GB |        | `vault.home.arpa` |
| `vm-k8s-control-01.home.arpa` | `192.168.178.231` | 2 vCPU | 4 GB |  32 GB |        |                   |
| `vm-k8s-control-02.home.arpa` | `192.168.178.232` | 2 vCPU | 4 GB |  32 GB |        |                   |
| `vm-k8s-control-03.home.arpa` | `192.168.178.233` | 2 vCPU | 4 GB |  32 GB |        |                   |
| `vm-k8s-worker-01.home.arpa`  | `192.168.178.236` | 2 vCPU | 4 GB |  32 GB |  32 GB |                   |
| `vm-k8s-worker-02.home.arpa`  | `192.168.178.237` | 2 vCPU | 4 GB |  32 GB |  32 GB |                   |
| `vm-k8s-worker-03.home.arpa`  | `192.168.178.238` | 2 vCPU | 4 GB |  32 GB |  32 GB |                   |

## Endpoints

| FQDN                                            | Type              | Via                          |
|-------------------------------------------------|-------------------|------------------------------|
| `k8s-api.home.arpa`                             | Kubernetes API    | Kubernetes API VIP           |
| `vault.home.arpa:8200/ui/`                      | Vault UI          | `vm-vault-01.home.arpa`      |
| `grafana.k8s.home.arpa`                         | HTTP application  | Kubernetes LoadBalancer VIPs |
| `longhorn.k8s.home.arpa`                        | HTTP application  | Kubernetes LoadBalancer VIPs |
| `opensearch.k8s.home.arpa`                      | HTTP application  | Kubernetes LoadBalancer VIPs |
| `demo-website.k8s.home.arpa`                    | HTTP application  | Kubernetes LoadBalancer VIPs |
| `demo-website-blue-green.k8s.home.arpa`         | HTTP application  | Kubernetes LoadBalancer VIPs |
| `demo-website-blue-green-preview.k8s.home.arpa` | HTTP application  | Kubernetes LoadBalancer VIPs |
| `demo-website-canary.k8s.home.arpa`             | HTTP application  | Kubernetes LoadBalancer VIPs |
| `argocd.k8s.home.arpa`                          | HTTP application  | Kubernetes LoadBalancer VIPs |
| `lldap.k8s.home.arpa`                           | HTTP application  | Kubernetes LoadBalancer VIPs |
