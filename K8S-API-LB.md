### vm-k8s-api-lb-01

```bash
qm clone 9001 222 --name vm-k8s-lb-01 --full 1
qm resize 222 scsi0 8G
qm set 222 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.222/24,gw=192.168.178.1 \
  --nameserver 192.168.178.203 \
  --ciuser ubuntu \
  --sshkeys ~/.ssh/homelab-ed25519.pub \
  --onboot 1
qm start 222

ssh ubuntu@192.168.178.222

sudo apt update -y
sudo apt install -y qemu-guest-agent haproxy keepalived
sudo systemctl start qemu-guest-agent

echo 'net.ipv4.ip_nonlocal_bind = 1' | sudo tee /etc/sysctl.d/99-nonlocal-bind.conf
sudo sysctl -p /etc/sysctl.d/99-nonlocal-bind.conf

sudo tee /etc/haproxy/haproxy.cfg >/dev/null <<'EOF'
global
    node vm-k8s-api-lb-01
    user haproxy
    group haproxy
    log /dev/log local0
    log /dev/log local1 notice
    maxconn 20480

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 5s
    timeout client  1m
    timeout server  1m
    default-server  inter 2s fall 2 rise 2
    
listen stats
    bind 192.168.178.222:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 5s
    stats show-node

frontend k8s-api
    bind 192.168.178.221:6443
    default_backend k8s-api-backend

backend k8s-api-backend
    balance roundrobin
    option  tcp-check
    server cp01 192.168.178.224:6443 check
    server cp02 192.168.178.225:6443 check
    server cp03 192.168.178.226:6443 check
EOF

sudo haproxy -c -f /etc/haproxy/haproxy.cfg
sudo systemctl enable --now haproxy

sudo useradd --system --user-group --no-create-home --shell /usr/sbin/nologin --home-dir /nonexistent keepalived_script

sudo tee /etc/keepalived/keepalived.conf >/dev/null <<'EOF'
global_defs {
  script_user keepalived_script
  enable_script_security
}

vrrp_script chk_haproxy {
  script "/usr/bin/pgrep -x haproxy"
  interval 2
  fall 2
  rise 2
}

vrrp_instance VI_51 {
  state BACKUP
  interface eth0
  virtual_router_id 51
  priority 101
  advert_int 1
  nopreempt
  garp_master_delay 1
  garp_master_repeat 2
  
  authentication {
    auth_type PASS
    auth_pass 1fta7ix8
  }

  unicast_src_ip 192.168.178.222
  unicast_peer {
    192.168.178.223
  }

  track_script {
    chk_haproxy
  }

  virtual_ipaddress {
    192.168.178.221/24 dev eth0
  }
}
EOF

sudo keepalived -t
sudo systemctl enable --now keepalived
```

### vm-k8s-api-lb-02

```bash
qm clone 9001 223 --name vm-k8s-lb-02 --full 1
qm resize 223 scsi0 8G
qm set 223 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.223/24,gw=192.168.178.1 \
  --nameserver 192.168.178.203 \
  --ciuser ubuntu \
  --sshkeys ~/.ssh/homelab-ed25519.pub \
  --onboot 1
qm start 223

ssh ubuntu@192.168.178.223

sudo apt update -y
sudo apt install -y qemu-guest-agent haproxy keepalived
sudo systemctl start qemu-guest-agent

echo 'net.ipv4.ip_nonlocal_bind = 1' | sudo tee /etc/sysctl.d/99-nonlocal-bind.conf
sudo sysctl -p /etc/sysctl.d/99-nonlocal-bind.conf

sudo tee /etc/haproxy/haproxy.cfg >/dev/null <<'EOF'
global
    node vm-k8s-api-lb-02
    user haproxy
    group haproxy
    log /dev/log local0
    log /dev/log local1 notice
    maxconn 20480

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 5s
    timeout client  1m
    timeout server  1m
    default-server  inter 2s fall 2 rise 2
    
listen stats
    bind 192.168.178.223:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 5s
    stats show-node

frontend k8s-api
    bind 192.168.178.221:6443
    default_backend k8s-api-backend

backend k8s-api-backend
    balance roundrobin
    option  tcp-check
    server cp01 192.168.178.224:6443 check
    server cp02 192.168.178.225:6443 check
    server cp03 192.168.178.226:6443 check
EOF

sudo haproxy -c -f /etc/haproxy/haproxy.cfg
sudo systemctl enable --now haproxy

sudo useradd --system --user-group --no-create-home --shell /usr/sbin/nologin --home-dir /nonexistent keepalived_script

sudo tee /etc/keepalived/keepalived.conf >/dev/null <<'EOF'
global_defs {
  script_user keepalived_script
  enable_script_security
}

vrrp_script chk_haproxy {
  script "/usr/bin/pgrep -x haproxy"
  interval 2
  fall 2
  rise 2
}

vrrp_instance VI_51 {
  state BACKUP
  interface eth0
  virtual_router_id 51
  priority 100
  advert_int 1
  nopreempt
  garp_master_delay 1
  garp_master_repeat 2
  
  authentication {
    auth_type PASS
    auth_pass 1fta7ix8
  }

  unicast_src_ip 192.168.178.223
  unicast_peer {
    192.168.178.222
  }

  track_script {
    chk_haproxy
  }

  virtual_ipaddress {
    192.168.178.221/24 dev eth0
  }
}
EOF

sudo keepalived -t
sudo systemctl enable --now keepalived
```

```bash
ip -br a

sudo journalctl -u keepalived -b
sudo journalctl -u keepalived -b | egrep -i 'MASTER|BACKUP|FAULT|state'

sudo journalctl -u haproxy -b
```