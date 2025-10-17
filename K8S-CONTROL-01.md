### vm-k8s-control-01

```bash
qm clone 9001 224 --name vm-k8s-control-01 --full 1
qm resize 224 scsi0 32G
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

# sudo kubeadm config images pull
# kubeadm config images list

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
# kubeadm configuration
#
sudo install -d -m 0750 /etc/kubernetes/kubeadm

cat <<'EOF' | sudo tee /etc/kubernetes/kubeadm/kubeadm.yaml >/dev/null
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration

skipPhases:
  - addon/kube-proxy
  
nodeRegistration:
  criSocket: "unix:///run/containerd/containerd.sock"

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

#
# kubectl config for the current user
#
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get csr --sort-by=.metadata.creationTimestamp | grep Pending
CSR_NAME=$(kubectl get csr --sort-by=.metadata.creationTimestamp | grep control | grep Pending | tail -n1 | awk '{print $1}')
echo $CSR_NAME
kubectl certificate approve $CSR_NAME

#
# Post-init checks
#
timedatectl status
timedatectl timesync-status

kubectl describe node $(hostname) | grep Taints
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# kubectl taint nodes vm-k8s-control-01 node-role.kubernetes.io/control-plane:NoSchedule

kubectl get nodes -o wide
kubectl get pods -A -o wide
kubectl get --raw='/readyz?verbose'
kubectl get --raw='/livez?verbose'
curl --cacert /etc/kubernetes/pki/ca.crt https://k8s-api.home.arpa:6443/readyz?verbose
curl --cacert /etc/kubernetes/pki/ca.crt https://k8s-api.home.arpa:6443/livez?verbose

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

ipam:
  mode: cluster-pool
  operator:
    clusterPoolIPv4PodCIDRList:
      - 10.244.0.0/16
    clusterPoolIPv4MaskSize: 24
EOF

cat <<'EOF' | sudo tee /etc/kubernetes/cilium/values.operator-1.yaml >/dev/null
operator:
  replicas: 1
EOF

cat <<'EOF' | sudo tee /etc/kubernetes/cilium/values.operator-2.yaml >/dev/null
operator:
  replicas: 2
EOF

helm upgrade --install cilium cilium/cilium \
  --version 1.18.2 \
  --namespace kube-system \
  -f /etc/kubernetes/cilium/values.yaml \
  -f /etc/kubernetes/cilium/values.operator-1.yaml
  
watch kubectl get pods -n kube-system -o wide
kubectl get nodes -o wide
kubectl -n kube-system rollout status ds/cilium
kubectl -n kube-system rollout status deploy/coredns

kubectl -n kube-system exec "$(kubectl -n kube-system get pod -l k8s-app=cilium -o name | head -n1)" -- cilium status
  
# https://github.com/cilium/cilium-cli/releases
wget https://github.com/cilium/cilium-cli/releases/download/v0.18.7/cilium-linux-amd64.tar.gz
tar xzvfC cilium-linux-amd64.tar.gz .
sudo install -m 0755 ./cilium /usr/local/bin/cilium
rm ./cilium-linux-amd64.tar.gz; rm ./cilium

cilium connectivity test \
  --single-node \
  --tolerations node-role.kubernetes.io/control-plane \
  --ip-families ipv4 \
  --print-flows

kubectl delete ns cilium-test-1

#
# After worker-nn was added
#
cilium connectivity test --ip-families ipv4 --print-flows

#
# MetalLB
#
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm upgrade --install metallb metallb/metallb \
  --version 0.15.2 \
  -n metallb-system --create-namespace
  
watch kubectl get pods -n metallb-system -o wide
  
kubectl label ns metallb-system \
  pod-security.kubernetes.io/enforce=privileged \
  pod-security.kubernetes.io/warn=privileged \
  pod-security.kubernetes.io/audit=privileged \
  --overwrite

sudo install -d -m 0755 /etc/kubernetes/metallb

cat <<'EOF' | sudo tee /etc/kubernetes/metallb/pool.yaml >/dev/null
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: metallb-pool
  namespace: metallb-system
  labels:
    k8s.home.arpa/pool: metallb-pool-ingress
spec:
  addresses:
    - 192.168.178.211/32

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: metallb-pool-ingress
  namespace: metallb-system
spec:
  ipAddressPoolSelectors:
    - matchLabels:
        k8s.home.arpa/pool: metallb-pool-ingress
EOF

kubectl apply -f /etc/kubernetes/metallb/pool.yaml
kubectl -n metallb-system get ipaddresspools.metallb.io,l2advertisements.metallb.io

kubectl -n metallb-system get pods -o wide
kubectl -n metallb-system get svc -o wide

#
# MetalLB Tests
#
sudo install -d -m 0755 /etc/kubernetes/metallb-tests

cat <<'EOF' | sudo tee /etc/kubernetes/metallb-tests/e2e.yaml >/dev/null
apiVersion: v1
kind: Namespace
metadata:
  name: metallb-tests
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metallb-test-e2e
  namespace: metallb-tests
  labels: 
    app.kubernetes.io/name: metallb-test-e2e
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: metallb-test-e2e
  template:
    metadata:
      labels:
        app.kubernetes.io/name: metallb-test-e2e
    spec:
      containers:
        - name: nginx
          image: nginx:1.29-alpine
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: metallb-test-e2e
  namespace: metallb-tests
  labels:
    app.kubernetes.io/name: metallb-test-e2e
spec:
  type: LoadBalancer
  selector:
    app.kubernetes.io/name: metallb-test-e2e
  ports:
    - port: 80
      targetPort: 80
EOF

kubectl apply -f /etc/kubernetes/metallb-tests/e2e.yaml
kubectl -n metallb-tests get svc metallb-test-e2e
kubectl -n metallb-tests describe svc metallb-test-e2e
curl -s http://192.168.178.211 | grep Welcome
kubectl delete namespace metallb-tests

#
# metrics-server
#
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
  --version 3.13.0 \
  -n kube-system
  
watch kubectl get pods -n kube-system -o wide   
kubectl -n kube-system get deploy,pods -l app.kubernetes.io/name=metrics-server -o wide
kubectl top nodes
kubectl top pods -A --sort-by=memory

#
# Envoy Gateway
#
helm template envoy-gateway oci://docker.io/envoyproxy/gateway-crds-helm \
  --version v1.5.3 \
  --set crds.gatewayAPI.enabled=true \
  --set crds.gatewayAPI.channel=standard \
  --set crds.envoyGateway.enabled=true \
  | kubectl apply --server-side -f -

helm install envoy-gateway oci://docker.io/envoyproxy/gateway-helm \
  --version v1.5.3 \
  -n envoy-gateway-system \
  --create-namespace \
  --skip-crds
  
watch kubectl get pods -n envoy-gateway-system

sudo install -d -m 0755 /etc/kubernetes/envoy-gateway

cat <<'EOF' | sudo tee /etc/kubernetes/envoy-gateway/envoyproxy.yaml >/dev/null
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: envoy-gateway-default
  namespace: envoy-gateway-system
spec:
  mergeGateways: true
EOF

kubectl apply -f /etc/kubernetes/envoy-gateway/envoyproxy.yaml

cat <<'EOF' | sudo tee /etc/kubernetes/envoy-gateway/gatewayclass.yaml >/dev/null
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: envoy-gateway
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
  parametersRef:
    group: gateway.envoyproxy.io
    kind: EnvoyProxy
    name: envoy-gateway-default
    namespace: envoy-gateway-system
EOF

kubectl apply -f /etc/kubernetes/envoy-gateway/gatewayclass.yaml

kubectl get gatewayclass envoy-gateway

#
# Envoy Gateway Tests
#
sudo install -d -m 0755 /etc/kubernetes/envoy-gateway-tests

cat <<'EOF' | sudo tee /etc/kubernetes/envoy-gateway-tests/e2e.yaml >/dev/null
apiVersion: v1
kind: Namespace
metadata:
  name: envoy-gateway-tests
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: envoy-gateway-test-e2e-deploy
  namespace: envoy-gateway-tests
  labels:
    app.kubernetes.io/name: envoy-gateway-test-e2e
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: envoy-gateway-test-e2e
  template:
    metadata:
      labels:
        app.kubernetes.io/name: envoy-gateway-test-e2e
    spec:
      containers:
        - name: nginx
          image: nginx:1.29-alpine
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: envoy-gateway-test-e2e-svc
  namespace: envoy-gateway-tests
  labels:
    app.kubernetes.io/name: envoy-gateway-test-e2e
spec:
  type: ClusterIP
  selector:
    app.kubernetes.io/name: envoy-gateway-test-e2e
  ports:
    - port: 80
      targetPort: 80
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: envoy-gateway-test-e2e-gw
  namespace: envoy-gateway-tests
  labels:
    app.kubernetes.io/name: envoy-gateway-test-e2e
spec:
  gatewayClassName: envoy-gateway
  listeners:
    - name: http
      hostname: envoy-gateway-test-e2e.k8s.home.arpa
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: Same
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: envoy-gateway-test-e2e-route
  namespace: envoy-gateway-tests
  labels:
    app.kubernetes.io/name: envoy-gateway-test-e2e
spec:
  parentRefs:
    - name: envoy-gateway-test-e2e-gw
      sectionName: http
  hostnames:
    - envoy-gateway-test-e2e.k8s.home.arpa
  rules:
    - backendRefs:
        - name: envoy-gateway-test-e2e-svc
          port: 80
EOF

kubectl apply -f /etc/kubernetes/envoy-gateway-tests/e2e.yaml
kubectl -n envoy-gateway-tests rollout status deploy/envoy-gateway-test-e2e-deploy --timeout=120s
kubectl -n envoy-gateway-tests wait gateway/envoy-gateway-test-e2e-gw --for=condition=Programmed --timeout=180s
kubectl -n envoy-gateway-tests get gateway envoy-gateway-test-e2e-gw
curl -sS --fail -H "Host: envoy-gateway-test-e2e.k8s.home.arpa" http://192.168.178.211/ | grep -i "Welcome"
kubectl delete namespace envoy-gateway-tests
```