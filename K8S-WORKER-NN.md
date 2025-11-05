### vm-k8s-worker-01

```bash
ssh ubuntu@192.168.178.227
ssh ubuntu@192.168.178.228

#
# Settings
#
K8S_VERSION="v1.34"
PAUSE_VERSION="3.10.1"

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
sudo apt-get install -y kubelet kubeadm
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
# Run at control-NN node
#
sudo kubeadm token create --ttl 24h0m0s --print-join-command

#
# Run at worker-NN node
#
sudo kubeadm join k8s-api.home.arpa:6443 --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash> \
  --cri-socket unix:///run/containerd/containerd.sock
  
#
# Run at control-NN node
#
kubectl label node vm-k8s-worker-01 node-role.kubernetes.io/worker='' --overwrite
kubectl label node vm-k8s-worker-02 node-role.kubernetes.io/worker='' --overwrite

kubectl get csr --sort-by=.metadata.creationTimestamp | grep Pending
kubectl certificate approve $(kubectl get csr --sort-by=.metadata.creationTimestamp | grep worker | grep Pending | tail -n1 | awk '{print $1}')

kubectl get nodes -o wide
```