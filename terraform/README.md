```bash
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

qm create 9001 \
  --name ubuntu-24.04-cloudimg \
  --machine q35 --ostype l26 \
  --memory 1024 --balloon 1024 \
  --cpu host --cores 1 --sockets 1 --numa 0 \
  --scsihw virtio-scsi-single \
  --scsi0 local-lvm:0,import-from=/root/noble-server-cloudimg-amd64.img,discard=on,iothread=1,ssd=1 \
  --bios ovmf --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=1 \
  --boot order=scsi0 \
  --net0 virtio,bridge=vmbr0,firewall=1 \
  --serial0 socket --vga serial0 \
  --rng0 source=/dev/urandom \
  --agent 1
  
qm template 9001
```


```bash
pveam update

pveam available --section system

pveam download local debian-12-standard_12.7-1_amd64.tar.zst

pveam list local
```

```bash
docker compose -f docker-compose.yml run --rm terraform init

docker compose -f docker-compose.yml run --rm terraform fmt -recursive

docker compose -f docker-compose.yml run --rm terraform validate

docker compose -f docker-compose.yml run --rm terraform plan
```