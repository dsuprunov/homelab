### vm-k8s-api-lb-01 (k8s api load balancer virtual machine)

1) Install packages and configure system
```bash
sudo apt update -y
sudo apt install -y procps haproxy keepalived

echo 'net.ipv4.ip_nonlocal_bind = 1' | sudo tee /etc/sysctl.d/99-nonlocal-bind.conf
sudo sysctl -p /etc/sysctl.d/99-nonlocal-bind.conf
sudo sysctl net.ipv4.ip_nonlocal_bind
```

2) Configure HAProxy
```bash
cat <<'EOF' | sudo tee /etc/haproxy/haproxy.cfg >/dev/null
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
    default-server inter 2s fall 2 rise 2

listen stats
    bind 192.168.178.207:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 5s
    stats show-node

frontend k8s-api
    bind 192.168.178.225:6443
    default_backend k8s-api-backend

backend k8s-api-backend
    balance roundrobin
    option tcp-check
    server k8s-control-01 192.168.178.226:6443 check
    # server k8s-control-02 192.168.178.227:6443 check
    # server k8s-control-03 192.168.178.228:6443 check
EOF

sudo haproxy -c -f /etc/haproxy/haproxy.cfg
sudo systemctl enable haproxy
sudo systemctl restart haproxy
sudo systemctl status haproxy --no-pager
```

3) Configure Keepalived
```bash
sudo useradd --system --user-group --no-create-home --shell /usr/sbin/nologin --home-dir /nonexistent keepalived_script

cat <<'EOF' | sudo tee /etc/keepalived/keepalived.conf >/dev/null
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
  state MASTER
  interface eth0
  virtual_router_id 51
  priority 101
  advert_int 1
  # nopreempt
  garp_master_delay 1
  garp_master_repeat 2

  authentication {
    auth_type PASS
    auth_pass 1fta7ix8
  }

  # For single API LB keep unicast disabled.
  # When second API LB appears:
  # - set this node to BACKUP and priority 100
  # - configure lb-02 as BACKUP and priority 101
  # - uncomment unicast on both nodes and set each other's IP
  # - enable "nopreempt" on both nodes
  # unicast_src_ip 192.168.178.207
  # unicast_peer {
  #   192.168.178.208
  # }

  track_script {
    chk_haproxy
  }

  virtual_ipaddress {
    192.168.178.225/24 dev eth0
  }
}
EOF

sudo keepalived -t
sudo systemctl enable --now keepalived
sudo systemctl status keepalived --no-pager
```
