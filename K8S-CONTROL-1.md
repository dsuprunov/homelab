### vm-k8s-control-01

```bash
qm clone 9001 224 --name vm-k8s-control-01 --full 1
qm resize 224 scsi0 16G
qm set 224 \
  --sockets 1 --cores 2 \
  --memory 3072 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.224/24,gw=192.168.178.1 \
  --nameserver 192.168.178.203 \
  --ciuser ubuntu \
  --sshkeys ~/.ssh/homelab-ed25519.pub \
  --onboot 1
qm start 224

ssh ubuntu@192.168.178.224

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
# System configuration (swap, kernel modules, sysctl)
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
# Configure containerd (SystemdCgroup, CRI socket)
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
# Kubernetes APT repository
#
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg 

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#
# Install Kubernetes components
#
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

sudo kubeadm config images pull
kubeadm config images list

#
# Sanity checks
#
getent hosts k8s-api.home.arpa
containerd --version
sudo test -S /run/containerd/containerd.sock && echo "CRI socket OK" || echo "CRI socket MISSING"
grep -n 'SystemdCgroup *= *true' /etc/containerd/config.toml || echo "SystemdCgroup NOT SET"
sysctl net.ipv4.ip_forward

#
# kubeadm configuration
#
sudo install -d -m 0750 /etc/kubernetes/kubeadm
cat <<'EOF' | sudo tee /etc/kubernetes/kubeadm/kubeadm.yaml >/dev/null
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration

localAPIEndpoint:
  advertiseAddress: "192.168.178.224"
  bindPort: 6443

---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration

clusterName: "homelab"
controlPlaneEndpoint: "k8s-api.home.arpa:6443"

networking:
  serviceSubnet: "10.96.0.0/12"
  podSubnet: "10.244.0.0/16"

apiServer:
  certSANs:
    - "k8s-api.home.arpa"
    - "192.168.178.221"
    
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration

serverTLSBootstrap: true
EOF

#
# Validate and initialize the control plane
#
sudo chmod 640 /etc/kubernetes/kubeadm/kubeadm.yaml
sudo kubeadm config validate --config /etc/kubernetes/kubeadm/kubeadm.yaml
sudo kubeadm init --config /etc/kubernetes/kubeadm/kubeadm.yaml --upload-certs

# 
# If kubeadm warns about pause image mismatch, align containerd to what kubeadm expects 
#
# W1002 detected that the sandbox image "registry.k8s.io/pause:3.8" of the container runtime is inconsistent
# with that used by kubeadm. It is recommended to use "registry.k8s.io/pause:3.10.1" as the CRI sandbox image.
#
# ===== BEGIN: pause-image mismatch fix =====
PAUSE_VERSION="$(
  curl -fsSL \
  "https://raw.githubusercontent.com/kubernetes/kubernetes/$(kubeadm version -o short)/cmd/kubeadm/app/constants/constants.go" \
  | sed -n 's/^\s*PauseVersion\s*=\s*"\(.*\)".*/\1/p'
)"
echo "Using pause:${PAUSE_VERSION}"
sudo sed -ri \
  "s~^\s*sandbox_image\s*=.*~sandbox_image = \"registry.k8s.io/pause:${PAUSE_VERSION}\"~" /etc/containerd/config.toml \
  || printf 'Add under [plugins."io.containerd.grpc.v1.cri"]: sandbox_image = "registry.k8s.io/pause:%s"\n' "${PAUSE_VERSION}"
grep -n 'sandbox_image' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl restart kubelet
#
# ===== END: pause-image mismatch fix =====
#

# kubectl get csr --sort-by=.metadata.creationTimestamp | grep Pending | awk '{print $1}'
CSR_NAME=$(kubectl get csr | grep Pending | awk '{print $1}')
echo $CSR_NAME
kubectl certificate approve $CSR_NAME

#
# kubectl config for the current user
#
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#
# Post-init checks
#
timedatectl status
timedatectl timesync-status

kubectl describe node $(hostname) | grep Taints
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

kubectl taint nodes vm-k8s-control-01 node-role.kubernetes.io/control-plane:NoSchedule

kubectl get nodes -o wide
kubectl get pods -A -o wide
kubectl get --raw='/readyz?verbose'
kubectl get --raw='/livez?verbose'
curl --cacert /etc/kubernetes/pki/ca.crt https://k8s-api.home.arpa:6443/readyz?verbose
curl --cacert /etc/kubernetes/pki/ca.crt https://k8s-api.home.arpa:6443/livez?verbose
```