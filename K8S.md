### Infra overview

| Role        | Hostname (FQDN)               | IP Address      |    CPU |  RAM | Disk 0 | Disk 1 |
|-------------|-------------------------------|-----------------|-------:|-----:|-------:|-------:|
| Ingress VIP | `k8s.home.arpa`               | 192.168.178.211 |        |      |        |        |
| API VIP     | `k8s-api.home.arpa`           | 192.168.178.221 |        |      |        |        |
| LB #1       | `vm-k8s-api-lb-01.home.arpa`  | 192.168.178.222 | 1 vCPU | 1 GB |   8 GB |        |
| LB #2       | `vm-k8s-api-lb-02.home.arpa`  | 192.168.178.223 | 1 vCPU | 1 GB |   8 GB |        |
| Control #1  | `vm-k8s-control-01.home.arpa` | 192.168.178.224 | 2 vCPU | 3 GB |  32 GB |        |
| Control #2  | `vm-k8s-control-02.home.arpa` | 192.168.178.225 | 2 vCPU | 3 GB |  32 GB |        |
| Control #3  | `vm-k8s-control-03.home.arpa` | 192.168.178.226 | 2 vCPU | 3 GB |  32 GB |        |
| Worker #1   | `vm-k8s-worker-01.home.arpa`  | 192.168.178.227 | 4 vCPU | 4 GB |  64 GB |   16GB |
| Worker #2   | `vm-k8s-worker-02.home.arpa`  | 192.168.178.228 | 1 vCPU | 4 GB |  64 GB |        |
| Worker #3   | `vm-k8s-worker-03.home.arpa`  | 192.168.178.229 | 1 vCPU | 4 GB |  64 GB |        |

### Links

- K8S API LB #1 http://192.168.178.222:8404/stats
- K8S API LB #2 http://192.168.178.223:8404/stats

### Commands

```bash
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl >/dev/null
source /etc/bash_completion
```

```bash
kubectl top pods -A --sort-by=memory
kubectl top pods -A --sort-by=cpu
```