### vm-pi-hole

```bash
qm clone 9001 203 --name vm-pi-hole --full 1

qm resize 203 scsi0 16G

qm set 203 \
  --scsi2 local-lvm:cloudinit \
  --ipconfig0 ip=192.168.178.203/24,gw=192.168.178.1 \
  --nameserver 192.168.178.201 \
  --ciuser ubuntu \
  --sshkeys ~/.ssh/homelab-ed25519.pub \
  --onboot 1
  
qm start 203

ssh ubuntu@192.168.178.203

#
# System
#

sudo apt update
sudo apt install -y qemu-guest-agent nfs-common
sudo systemctl start qemu-guest-agent

#
# Docker
#
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl status docker

#
# pi-hole
#
sudo -i

mount -t nfs4 192.168.178.202:/vm-pi-hole /mnt
mkdir -p /mnt/pihole && chmod 2770 /mnt/pihole
umount /mnt

mkdir -p /root/pi-hole

echo "admin" > /root/pi-hole/.webpassword && chmod 600 /root/pi-hole/.webpassword

cat > /root/pi-hole/.env <<'EOF'
PIHOLE_IP=192.168.178.203
EOF 

cat > /root/pi-hole/docker-compose.yml <<'EOF'
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    restart: unless-stopped
    ports:
      - "${PIHOLE_IP}:53:53/tcp"
      - "${PIHOLE_IP}:53:53/udp"
      - "80:80/tcp"
      - "443:443/tcp"
    environment:
      TZ: 'Etc/UTC'
      FTLCONF_dns_listeningMode: "all"
      WEBPASSWORD_FILE: webpassword
      PIHOLE_UID: "3001"
      PIHOLE_GID: "3001"
    volumes:
      - pihole-data:/etc/pihole:rw,nocopy
    secrets:
      - webpassword
    cap_add:
      - NET_ADMIN
      - SYS_TIME
      - SYS_NICE

volumes:
  pihole-data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.178.202,nfsvers=4.2,rw
      device: ":/vm-pi-hole/pihole"
      
secrets:
  webpassword:
    file: ./.webpassword
EOF

docker compose -f /root/pi-hole/docker-compose.yml up -d

docker inspect pihole
docker logs -f pihole
```