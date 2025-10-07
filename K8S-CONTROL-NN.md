### vm-k8s-control-02

```bash
qm clone 9001 225 --name vm-k8s-control-02 --full 1
qm resize 225 scsi0 32G
qm set 225 \
  --sockets 1 --cores 2 \
  --memory 3072 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.225/24,gw=192.168.178.1 \
  --nameserver 192.168.178.203 \
  --ciuser ubuntu \
  --sshkeys ~/.ssh/homelab-ed25519.pub \
  --onboot 1
qm start 225

ssh ubuntu@192.168.178.225

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
sudo systemctl status qemu-guest-agent.service

#
# System configuration
#
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
# Install containerd (from Docker repository)
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

#
# Configure containerd
#
sudo mkdir -p -m 755 /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -ri 's/(SystemdCgroup\s*=\s*)false/\1true/' /etc/containerd/config.toml

sudo sed -ri \
  "s~^\s*sandbox_image\s*=.*~sandbox_image = \"registry.k8s.io/pause:${PAUSE_VERSION}\"~" /etc/containerd/config.toml \
  || printf 'Add under [plugins."io.containerd.grpc.v1.cri"]: sandbox_image = "registry.k8s.io/pause:%s"\n' "${PAUSE_VERSION}"

sudo systemctl restart containerd.service
sudo systemctl enable --now containerd.service

#
# Kubernetes
#
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

[ "$(stat -fc %T /sys/fs/cgroup)" = "cgroup2fs" ] \
  && echo "OK: cgroup v2 (cgroup2fs) detected" \
  || echo "INFO: cgroup v2 not default; Cilium will auto-mount a private cgroup v2"
  
mount | grep -q ' on /sys/fs/bpf ' && echo "OK: bpffs mounted" \
  || echo "INFO: bpffs not mounted; Cilium will auto-mount /sys/fs/bpf"

getent hosts k8s-api.home.arpa
containerd --version
sudo test -S /run/containerd/containerd.sock && echo "CRI socket OK" || echo "CRI socket MISSING"
grep -n 'SystemdCgroup *= *true' /etc/containerd/config.toml || echo "SystemdCgroup NOT SET"
sysctl net.ipv4.ip_forward

#
# Run at control-01 node
#
CERT_KEY=$(sudo kubeadm init phase upload-certs --upload-certs | tail -n1); echo "$CERT_KEY"
JOIN_CMD=$(sudo kubeadm token create --ttl 24h0m0s --print-join-command); echo "$JOIN_CMD"

#
# Run at control-NN node
#
sudo kubeadm join k8s-api.home.arpa:6443 \
  --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash> \
  --control-plane \
  --certificate-key <cert-key> \
  --cri-socket unix:///run/containerd/containerd.sock

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get csr --sort-by=.metadata.creationTimestamp | grep Pending
CSR_NAME=$(kubectl get csr --sort-by=.metadata.creationTimestamp | grep control | grep Pending | tail -n1 | awk '{print $1}')
echo $CSR_NAME
kubectl certificate approve $CSR_NAME

kubectl get nodes -o wide

kubectl -n kube-system exec etcd-vm-k8s-control-02 -- \
  sh -c 'ETCDCTL_API=3 etcdctl \
    --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/peer.crt \
    --key=/etc/kubernetes/pki/etcd/peer.key \
    endpoint status -w table'
    
#
# Run at control-01 node
#
helm upgrade --install cilium cilium/cilium \
  --version 1.18.2 \
  --namespace kube-system \
  -f /etc/kubernetes/cilium/values.yaml \
  -f /etc/kubernetes/cilium/values.operator-2.yaml
  
kubectl -n kube-system get pods -l 'io.cilium/app=operator' --sort-by=.spec.nodeName -o wide
```