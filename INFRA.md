# Infrastructure Overview

TODO `technitium`: two-phase provisioning flow
TODO `technitium`: tune (less caching, more forwarding)

## Network

| Pool                  | Size | Description               |
|-----------------------|------|---------------------------|
| `192.168.178.200-204` | 5    | Hardware / Proxmox nodes  |
| `192.168.178.205-224` | 20   | Virtual machines          |
| `192.168.178.225`     | 1    | Kubernetes API VIP        |
| `192.168.178.226-229` | 4    | Kubernetes Control Planes |
| `192.168.178.230-239` | 10   | Kubernetes Workers        |
| `192.168.178.240-249` | 10   | Load Balancer pool        |

## Hosts

| Host                          | Address           |    CPU |  RAM | Disk 0 | Disk 1 | Alias             | Notes                                        |
|-------------------------------|-------------------|-------:|-----:|-------:|-------:|-------------------|----------------------------------------------|
| `pve-01.home.arpa`            | `192.168.178.200` |        |      |        |        |                   |                                              |
| `vm-technitium-01.home.arpa`  | `192.168.178.205` | 1 vCPU | 1 GB |   8 GB |        | `ns.home.arpa`    | http://ns.home.arpa:5380                     |
| `vm-vault-01.home.arpa`       | `192.168.178.206` | 1 vCPU | 2 GB |   8 GB |        | `vault.home.arpa` | https://vault.home.arpa:8200                 |
| `vm-k8s-api-lb-01.home.arpa`  | `192.168.178.207` | 1 vCPU | 1 GB |   8 GB |        |                   | http://vm-k8s-api-lb-01.home.arpa:8404/stats |
| `vm-k8s-control-01.home.arpa` | `192.168.178.226` | 2 vCPU | 4 GB |  16 GB |        |                   |                                              |
| `vm-k8s-worker-01.home.arpa`  | `192.168.178.230` | 2 vCPU | 4 GB |  32 GB |  32 GB |                   |                                              |
| `vm-k8s-worker-02.home.arpa`  | `192.168.178.231` | 2 vCPU | 4 GB |  32 GB |  32 GB |                   |                                              |
| `vm-k8s-worker-03.home.arpa`  | `192.168.178.232` | 2 vCPU | 4 GB |  32 GB |  32 GB |                   |                                              |

## Virtual IPs

| Name                  | Address           | Notes              |
|-----------------------|-------------------|--------------------|
| `k8s-api.home.arpa`   | `192.168.178.225` | Kubernetes API VIP |
