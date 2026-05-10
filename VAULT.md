### vm-vault-01 (vault virtual machine)

1) Verify that the 1 GB `scsi1` disk is visible as `/dev/sdb`
```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL
```

2) Install HashiCorp Vault and required packages
```bash
sudo apt update
sudo apt install -y curl gpg openssl parted

curl -fsSL https://apt.releases.hashicorp.com/gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
VAULT_VERSION='2.0.0-1'
sudo apt install -y "vault=${VAULT_VERSION}"

vault --version
```

3) Partition, format, and mount the 1 GB `scsi1` disk for Vault data
```bash
sudo parted -s /dev/sdb mklabel gpt
sudo parted -s /dev/sdb mkpart primary ext4 1MiB 100%
sudo mkfs.ext4 -L vault-data /dev/sdb1

UUID=$(sudo blkid -s UUID -o value /dev/sdb1)
grep -q '/opt/vault/data' /etc/fstab \
  && echo '/opt/vault/data already exists in /etc/fstab, nothing added' \
  || echo "UUID=$UUID /opt/vault/data ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

sudo install -d -o vault -g vault -m 0750 /opt/vault/data
sudo systemctl daemon-reload
sudo mount -a
sudo chown vault:vault /opt/vault/data
sudo chmod 0750 /opt/vault/data

df -h /opt/vault/data
ls -ld /opt/vault/data
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
```

4) Create Vault TLS and configuration
```bash
sudo install -d -o vault -g vault -m 0750 /opt/vault/tls

sudo -u vault openssl req -x509 -newkey rsa:4096 -nodes -sha256 -days 3650 \
  -subj "/CN=vault.home.arpa" \
  -addext "subjectAltName=DNS:vault.home.arpa" \
  -keyout /opt/vault/tls/tls.key \
  -out /opt/vault/tls/tls.crt

cat <<'EOF' | sudo tee /etc/vault.d/vault.hcl >/dev/null
ui = true
disable_mlock = true

storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/vault/tls/tls.crt"
  tls_key_file  = "/opt/vault/tls/tls.key"
}

api_addr = "https://vault.home.arpa:8200"
EOF

sudo chown root:vault /etc/vault.d/vault.hcl
sudo chmod 0640 /etc/vault.d/vault.hcl
sudo systemctl enable --now vault
sudo systemctl status vault --no-pager

curl --insecure https://vault.home.arpa:8200/v1/sys/health
```

5) Initialize, unseal, and verify Vault
```bash
sudo -i

export VAULT_ADDR="https://vault.home.arpa:8200"
export VAULT_CACERT="/opt/vault/tls/tls.crt"

vault status

vault operator init -key-shares=1 -key-threshold=1 | tee /opt/vault/data/vault-init.txt
chmod 600 /opt/vault/data/vault-init.txt

UNSEAL_KEY=$(grep -m1 '^Unseal Key 1:' /opt/vault/data/vault-init.txt | awk '{print $4}')
ROOT_TOKEN=$(grep -m1 '^Initial Root Token:' /opt/vault/data/vault-init.txt | awk '{print $4}')

vault operator unseal "$UNSEAL_KEY"
vault status

vault login "$ROOT_TOKEN"
vault secrets enable -path=secret kv-v2
vault secrets list

vault kv put secret/vault-smoke-test status="ok" owner="vm-vault-01"
vault kv get secret/vault-smoke-test
vault kv metadata get secret/vault-smoke-test
vault kv delete secret/vault-smoke-test
vault kv get secret/vault-smoke-test
```
