### Infra overview

| Role           | Hostname (FQDN)                | IP Addres        |
|----------------|--------------------------------|------------------|
| DNS            | `vm-pihole.home.arpa`          | 192.168.178.201  |
| Vault          | `vm-vault.home.arpa`           | 192.168.178.202 |
| K8S API        | `k8s-api.home.arpa`            | 192.168.178.210  |
| K8S Ingress    | `k8s-ingress.home.arpa`        | 192.168.178.211  |
| K8S Control #1 | `vm-k8s-control-01.home.arpa`  | 192.168.178.210  |
| K8S Worker #1  | `vm-k8s-worker-01.home.arpa`   | 192.168.178.220  |
| K8S Worker #2  | `vm-k8s-worker-02.home.arpa`   | 192.168.178.221  |
| K8S Worker #3  | `vm-k8s-worker-03.home.arpa`   | 192.168.178.222  |

### Hosts

| Service                           | CName                   | Managed By   |
|-----------------------------------|-------------------------|--------------|
| http://pihole.home.arpa           | `vm-pihole.home.arpa`   | manual       |
| http://vault.home.arpa            | `vm-vault.home.arpa`    | manual       |
| http://grafana.k8s.home.arpa      | `k8s-ingress.home.arpa` | external-dns |
| http://dummy-portal.k8s.home.arpa | `k8s-ingress.home.arpa` | external-dns |

### kubectl config for the current user

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo 'source <(kubectl completion bash)' >>~/.bashrc
source ~/.bashrc
```