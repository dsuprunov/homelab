# Infrastructure Overview

## Network

| Pool                   | Description                  |
|------------------------|------------------------------|
| `192.168.178.201-205`  | Proxmox nodes                |
| `192.168.178.206-229`  | Virtual machines             |
| `192.168.178.230`      | Kubernetes API VIP           |
| `192.168.178.231-235`  | Kubernetes Control Planes    |
| `192.168.178.236-245`  | Kubernetes Workers           |
| `192.168.178.246-250`  | Kubernetes LoadBalancer VIPs |

## Hosts

`Active` means the VM is currently enabled in Terraform.
`Disabled` means the VM definition do not exist or commented out.

| VM ID | VM Name             | Address           | Terraform Module        | Status   | Purpose           |    CPU |  RAM | Disk 0 | Disk 1 | Alias             |
|------:|---------------------|-------------------|-------------------------|----------|-------------------|-------:|-----:|-------:|-------:|-------------------|
|   206 | `vm-coredns`        | `192.168.178.206` | `10-bootstrap`          | Active   | CoreDNS           | 1 vCPU | 1 GB |   8 GB |        | `ns.home.arpa`    |
|   207 | `vm-garage-01`      | `192.168.178.207` | `20-core-services`      | Disabled | S3 object storage | 1 vCPU | 1 GB |   8 GB |  32 GB | `s3.home.arpa`    |
|   208 | `vm-vault-01`       | `192.168.178.208` | `20-core-services`      | Disabled | HashiCorp Vault   | 1 vCPU | 1 GB |   8 GB |        | `vault.home.arpa` |
|   231 | `vm-k8s-control-01` | `192.168.178.231` | `30-kubeadm`/`30-talos` | Active   | K8s control plane | 2 vCPU | 4 GB |  32 GB |        |                   |
|   232 | `vm-k8s-control-02` | `192.168.178.232` | `30-kubeadm`/`30-talos` | Active   | K8s control plane | 2 vCPU | 4 GB |  32 GB |        |                   |
|   233 | `vm-k8s-control-03` | `192.168.178.233` | `30-kubeadm`/`30-talos` | Active   | K8s control plane | 2 vCPU | 4 GB |  32 GB |        |                   |
|   236 | `vm-k8s-worker-01`  | `192.168.178.236` | `30-kubeadm`/`30-talos` | Active   | K8s worker node   | 2 vCPU | 4 GB |  32 GB |  32 GB |                   |
|   237 | `vm-k8s-worker-02`  | `192.168.178.237` | `30-kubeadm`/`30-talos` | Active   | K8s worker node   | 2 vCPU | 4 GB |  32 GB |  32 GB |                   |
|   238 | `vm-k8s-worker-03`  | `192.168.178.238` | `30-kubeadm`/`30-talos` | Active   | K8s worker node   | 2 vCPU | 4 GB |  32 GB |  32 GB |                   |
|   251 | `vm-test-debian`    | `192.168.178.251` | `90-sandbox`            | Disabled | Debian test VM    | 1 vCPU | 1 GB |   8 GB |        |                   |
|   252 | `vm-test-ubuntu`    | `192.168.178.252` | `90-sandbox`            | Disabled | Ubuntu test VM    | 1 vCPU | 1 GB |   8 GB |        |                   |
