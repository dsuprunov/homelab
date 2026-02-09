### Infra overview

| Role        | Hostname (FQDN)               | IP Addres       |
|-------------|-------------------------------|-----------------|
| K8S API     | `k8s-api.home.arpa`           | 192.168.178.210 |
| K8S Ingress | `k8s-ingress.home.arpa`       | 192.168.178.211 |
| Control #1  | `vm-k8s-control-01.home.arpa` | 192.168.178.210 |
| Worker #1   | `vm-k8s-worker-01.home.arpa`  | 192.168.178.220 |
| Worker #2   | `vm-k8s-worker-02.home.arpa`  | 192.168.178.221 |
| Worker #3   | `vm-k8s-worker-03.home.arpa`  | 192.168.178.222 |

### Hosts

| Service                           | CName                   |
|-----------------------------------|-------------------------|
| http://flux.k8s.home.arpa         | `k8s-ingress.home.arpa` |
| http://grafana.k8s.home.arpa      | `k8s-ingress.home.arpa` |
| http://dummy-portal.k8s.home.arpa | `k8s-ingress.home.arpa` |

### kubectl config for the current user

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo 'source <(kubectl completion bash)' >>~/.bashrc
source ~/.bashrc
```

### flux 

```bash
kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -

kubectl -n flux-system create secret generic homelab-git-auth \
  --from-literal=username=git \
  --from-literal=password="---HIDDEN---" \
  --dry-run=client -o yaml | kubectl apply -f -
```