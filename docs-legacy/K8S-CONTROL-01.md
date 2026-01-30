### vm-k8s-control-01

```bash
ssh ubuntu@192.168.178.224

#
# Settings
#
K8S_VERSION="v1.34"
PAUSE_VERSION="3.10.1"
CILIUM_VERSION="1.18.3"
GATEWAY_API_VERSION="v1.2.0"

#
# VM agent (QEMU Guest Agent)
#
sudo apt-get update -y
sudo apt-get install -y qemu-guest-agent
sudo systemctl start qemu-guest-agent

#
# System configuration
#
timedatectl status | grep synchronized

sudo swapoff -a
sudo sed -ri 's/^\s*([^#]\S+\s+\S+\s+swap\s+\S+.*)$/# \1/g' /etc/fstab
free -h; swapon --show; grep -E '^\s*[^#].*\s+swap\s+' /etc/fstab || printf "\nfstab: swap disabled\n"

cat <<'EOF' | sudo tee /etc/modules-load.d/k8s.conf >/dev/null
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<'EOF' | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf >/dev/null
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl -p /etc/sysctl.d/99-kubernetes-cri.conf

#
# Install containerd
#
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update
sudo apt-get install -y containerd.io

sudo mkdir -p -m 755 /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -ri "s#(SystemdCgroup\s*=\s*)false#\1true#" /etc/containerd/config.toml
sudo sed -ri "s#^(\s*sandbox_image = ).*#\1\"registry.k8s.io/pause:${PAUSE_VERSION}\"#" /etc/containerd/config.toml

sudo systemctl restart containerd.service
sudo systemctl enable --now containerd.service

#
# Kubernetes 
#
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg 
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

#
# Sanity checks
#
uname -r # 5.10+ required
getent hosts k8s-api.home.arpa
containerd --version
sudo test -S /run/containerd/containerd.sock && echo "CRI socket OK" || echo "CRI socket MISSING"
grep -n "SystemdCgroup *= *true" /etc/containerd/config.toml || echo "SystemdCgroup NOT SET"
grep -n "sandbox_image *= *\"registry.k8s.io/pause:${PAUSE_VERSION}\"" /etc/containerd/config.toml || echo "Pause image ${PAUSE_VERSION} NOT SET"

#
# kubeadm configuration
#
sudo install -d -m 0750 /etc/kubernetes/kubeadm

cat <<'EOF' | sudo tee /etc/kubernetes/kubeadm/kubeadm.yaml >/dev/null
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration

nodeRegistration:
  criSocket: "unix:///run/containerd/containerd.sock"

localAPIEndpoint:
  advertiseAddress: "192.168.178.224"
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration

proxy:
  disabled: true

clusterName: "homelab"
controlPlaneEndpoint: "k8s-api.home.arpa:6443"

networking:
  serviceSubnet: "10.96.0.0/12"
  podSubnet: "10.244.0.0/16"

apiServer:
  certSANs:
    - "k8s-api.home.arpa"
    - "192.168.178.221"

controllerManager:
  extraArgs:
  - name: allocate-node-cidrs
    value: "true"
  - name: cluster-cidr
    value: "10.244.0.0/16"
  - name: node-cidr-mask-size
    value: "24"    
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration

serverTLSBootstrap: true
EOF

sudo chmod 640 /etc/kubernetes/kubeadm/kubeadm.yaml
sudo kubeadm config validate --config /etc/kubernetes/kubeadm/kubeadm.yaml
sudo kubeadm init --config /etc/kubernetes/kubeadm/kubeadm.yaml --upload-certs

#
# kubectl config for the current user
#
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo 'source <(kubectl completion bash)' >>~/.bashrc
source ~/.bashrc

kubectl get csr --sort-by=.metadata.creationTimestamp | grep Pending
kubectl certificate approve $(kubectl get csr --sort-by=.metadata.creationTimestamp | grep control | grep Pending | tail -n1 | awk '{print $1}')

#
# Post-init checks
#
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
kubectl get nodes -o wide
kubectl get pods -A -o wide
kubectl get --raw='/readyz?verbose'
kubectl get --raw='/livez?verbose'
curl --cacert /etc/kubernetes/pki/ca.crt https://k8s-api.home.arpa:6443/readyz?verbose
curl --cacert /etc/kubernetes/pki/ca.crt https://k8s-api.home.arpa:6443/livez?verbose

#
# Gateway API CRDs
#
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml

#
# Install Helm
#
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh

#
# Install Cilium
#
helm repo add cilium https://helm.cilium.io/
helm repo update

sudo install -d -m 0755 /etc/kubernetes/cilium

cat <<'EOF' | sudo tee /etc/kubernetes/cilium/values.yaml >/dev/null
kubeProxyReplacement: true
k8sServiceHost: "k8s-api.home.arpa"
k8sServicePort: 6443

devices: "eth0"

nodePort:
  directRoutingDevice: "eth0"

ipam:
  mode: kubernetes
    
socketLB:
  enabled: true
  hostNamespaceOnly: true
  
cni:
  exclusive: true
  
l2announcements:
  enabled: true
  
envoy:
  enabled: true
  
gatewayAPI:
  enabled: true
  
debug:
  enabled: false
EOF

helm upgrade --install cilium cilium/cilium \
  --version ${CILIUM_VERSION} \
  --namespace kube-system \
  -f /etc/kubernetes/cilium/values.yaml
  
watch kubectl get pods -n kube-system -o wide
kubectl get nodes -o wide
kubectl -n kube-system rollout status ds/cilium
kubectl -n kube-system rollout status deploy/coredns

kubectl -n kube-system exec ds/cilium -- cilium status

cat <<'EOF' | sudo tee /etc/kubernetes/cilium/lb-ip-pool.yaml >/dev/null
apiVersion: cilium.io/v2
kind: CiliumLoadBalancerIPPool
metadata:
  name: ingress-vip
spec:
  blocks:
    - start: "192.168.178.211"
      stop:  "192.168.178.211"
EOF

kubectl apply -f /etc/kubernetes/cilium/lb-ip-pool.yaml

cat <<'EOF' | sudo tee /etc/kubernetes/cilium/cilium-l2-policy.yaml >/dev/null
apiVersion: cilium.io/v2alpha1
kind: CiliumL2AnnouncementPolicy
metadata:
  name: l2-gateway-vip
spec:
  interfaces:
    - "^eth0$"
  loadBalancerIPs: true
EOF

kubectl apply -f /etc/kubernetes/cilium/cilium-l2-policy.yaml

cat <<'EOF' | sudo tee /etc/kubernetes/cilium/cilium-gateway.yaml >/dev/null
apiVersion: v1
kind: Namespace
metadata:
  name: cilium-gateway
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: public
  namespace: cilium-gateway
spec:
  gatewayClassName: cilium
  addresses:
    - type: IPAddress
      value: 192.168.178.211
  listeners:
    - name: http-k8s-home-arpa
      hostname: "*.k8s.home.arpa"
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: All
    # - name: http-xxx-com
    #   hostname: xxx.com
    #   port: 80
    #   protocol: HTTP
    #   allowedRoutes:
    #     namespaces:
    #       from: All
    # - name: http-yyy-net
    #   hostname: yyy.net
    #   port: 80
    #   protocol: HTTP
    #   allowedRoutes:
    #     namespaces:
    #       from: All
EOF

kubectl apply -f /etc/kubernetes/cilium/cilium-gateway.yaml

#
# metrics-server
#
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
  --version 3.13.0 \
  -n kube-system
  
watch kubectl get pods -n kube-system -o wide   
kubectl top nodes
kubectl top pods -A --sort-by=memory
```