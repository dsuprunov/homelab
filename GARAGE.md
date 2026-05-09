### vm-garage-01 (garage virtual machine)

1) Verify that the 32 GB `scsi1` disk is visible as `/dev/sdb`
```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL
```

2) Install Garage binary and required packages
```bash
sudo apt update
sudo apt install -y curl ca-certificates openssl parted

sudo useradd --system --home-dir /nonexistent --shell /usr/sbin/nologin garage

GARAGE_VERSION='v2.3.0'

sudo curl -fL "https://garagehq.deuxfleurs.fr/_releases/${GARAGE_VERSION}/x86_64-unknown-linux-musl/garage" -o /usr/local/bin/garage
sudo chmod 0755 /usr/local/bin/garage

garage --version
```

3) Partition, format, and mount the 32 GB `scsi1` disk for Garage data
```bash
sudo parted -s /dev/sdb mklabel gpt
sudo parted -s /dev/sdb mkpart primary ext4 1MiB 100%
sudo mkfs.ext4 -L garage-data /dev/sdb1

UUID=$(sudo blkid -s UUID -o value /dev/sdb1)
grep -q '/var/lib/garage' /etc/fstab \
  && echo '/var/lib/garage already exists in /etc/fstab, nothing added' \
  || echo "UUID=$UUID /var/lib/garage ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

sudo install -d -o root -g root -m 0755 /var/lib/garage
sudo systemctl daemon-reload
sudo mount -a

sudo install -d -o garage -g garage -m 0750 /var/lib/garage/meta /var/lib/garage/data
df -h /var/lib/garage
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
```

4) Create Garage configuration
```bash
RPC_SECRET=$(openssl rand -hex 32)
ADMIN_TOKEN=$(openssl rand -base64 32)
METRICS_TOKEN=$(openssl rand -base64 32)

sudo install -o root -g garage -m 0640 /dev/stdin /etc/garage.toml <<EOF
metadata_dir = "/var/lib/garage/meta"
data_dir = "/var/lib/garage/data"
db_engine = "sqlite"

replication_factor = 1
rpc_bind_addr = "0.0.0.0:3901"
rpc_public_addr = "192.168.178.207:3901"
rpc_secret = "$RPC_SECRET"

[s3_api]
api_bind_addr = "0.0.0.0:3900"
s3_region = "us-east-1"

[admin]
api_bind_addr = "127.0.0.1:3903"
admin_token = "$ADMIN_TOKEN"
metrics_token = "$METRICS_TOKEN"
EOF

sudo ls -l /etc/garage.toml
```

5) Create systemd service and start Garage in single-node mode
```bash
cat <<'EOF' | sudo tee /etc/systemd/system/garage.service >/dev/null
[Unit]
Description=Garage S3 object storage
After=network-online.target
Wants=network-online.target

[Service]
User=garage
Group=garage
Environment=RUST_LOG=garage=info
ExecStart=/usr/local/bin/garage -c /etc/garage.toml server --single-node
Restart=on-failure
RestartSec=2s
LimitNOFILE=1048576
NoNewPrivileges=true
ProtectSystem=full
ProtectHome=true
ReadWritePaths=/var/lib/garage

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now garage
sudo systemctl status garage --no-pager
sudo ss -lntp | grep -E ':3900|:3901|:3903'
```

6) Verify cluster status
```bash
sudo garage -c /etc/garage.toml status
```

7) Useful checks
```bash
systemctl status garage --no-pager
journalctl -u garage -n 100 --no-pager
sudo garage -c /etc/garage.toml status
df -h /var/lib/garage
```

8) Smoke-test S3 access
```bash
SMOKE_TEST_BUCKET='smoke-test'
SMOKE_TEST_KEY='smoke-test-key'

sudo garage -c /etc/garage.toml bucket create "$SMOKE_TEST_BUCKET"
sudo garage -c /etc/garage.toml key create "$SMOKE_TEST_KEY" | tee ~/garage-smoke-test-key.txt
sudo garage -c /etc/garage.toml bucket allow \
  --read \
  --write \
  --owner \
  "$SMOKE_TEST_BUCKET" \
  --key "$SMOKE_TEST_KEY"

chmod 600 ~/garage-smoke-test-key.txt
sudo garage -c /etc/garage.toml bucket info "$SMOKE_TEST_BUCKET"
sudo garage -c /etc/garage.toml key info "$SMOKE_TEST_KEY"

ACCESS_KEY=$(grep '^Key ID:' ~/garage-smoke-test-key.txt | awk '{print $3}')
SECRET_KEY=$(grep '^Secret key:' ~/garage-smoke-test-key.txt | awk '{print $3}')

install -m 600 /dev/stdin ~/.garage-smoke-test.env <<EOF
export AWS_ACCESS_KEY_ID='$ACCESS_KEY'
export AWS_SECRET_ACCESS_KEY='$SECRET_KEY'
export AWS_DEFAULT_REGION='us-east-1'
export GARAGE_S3_ENDPOINT='http://s3.home.arpa:3900'
EOF

sudo apt update
sudo apt install -y awscli

ls -l ~/.garage-smoke-test.env

source ~/.garage-smoke-test.env

aws --endpoint-url "$GARAGE_S3_ENDPOINT" s3 ls
echo 'garage smoke test' > /tmp/garage-smoke.txt
aws --endpoint-url "$GARAGE_S3_ENDPOINT" s3 cp /tmp/garage-smoke.txt "s3://${SMOKE_TEST_BUCKET}/garage-smoke.txt"
aws --endpoint-url "$GARAGE_S3_ENDPOINT" s3 ls "s3://${SMOKE_TEST_BUCKET}"
aws --endpoint-url "$GARAGE_S3_ENDPOINT" s3 cp "s3://${SMOKE_TEST_BUCKET}/garage-smoke.txt" /tmp/garage-smoke-download.txt
cat /tmp/garage-smoke-download.txt
```
