# Infrastructure Overview

## Network

| Pool                  | Size | Description                  |
|-----------------------|------|------------------------------|
| `192.168.178.200`     | 1    | Router                       |
| `192.168.178.201-210` | 10   | Proxmox nodes                |
| `10.10.0.1-119`       | 1    | Virtual machines             |
| `10.10.0.120`         | 1    | Kubernetes API VIP           |
| `10.10.0.121-150`     | 30   | Kubernetes Control Planes    |
| `10.10.0.151-180`     | 30   | Kubernetes Workers           |
| `10.10.0.181-190`     | 10   | Kubernetes LoadBalancer VIPs |

## Hosts

| Host                          | Address       |    CPU |  RAM | Disk 0 | Disk 1 | Alias             | Notes |
|-------------------------------|---------------|-------:|-----:|-------:|-------:|-------------------|-------|
| `vm-router.home.arpa`         | `10.10.0.1`   | 1 vCPU | 1 GB |   8 GB |        | `ns.home.arpa`    |       |
| `vm-k8s-control-01.home.arpa` | `10.10.0.121` | 2 vCPU | 4 GB |  16 GB |        |                   |       |
| `vm-k8s-worker-01.home.arpa`  | `10.10.0.151` | 2 vCPU | 4 GB |  32 GB |  32 GB |                   |       |
| `vm-k8s-worker-02.home.arpa`  | `10.10.0.152` | 2 vCPU | 4 GB |  32 GB |  32 GB |                   |       |
| `vm-k8s-worker-03.home.arpa`  | `10.10.0.153` | 2 vCPU | 4 GB |  32 GB |  32 GB |                   |       |

## Virtual IPs

| Name                    | Address        | Notes                  |
|-------------------------|----------------|------------------------|
| `k8s-api.home.arpa`     | `10.10.0.120` | Kubernetes API VIP     |
