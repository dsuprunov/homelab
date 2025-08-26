```bash
ssh root@192.168.178.201

wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

qm create 9001 \
  --name ubuntu-24.04-cloud-template \
  --memory 1024 --balloon 1024 \
  --cpu host --cores 1 --sockets 1 --numa 0 \
  --scsihw virtio-scsi-single \
  --scsi0 local-lvm:0,import-from=/root/noble-server-cloudimg-amd64.img,discard=on,iothread=1,ssd=1 \
  --boot order=scsi0 \
  --net0 virtio,bridge=vmbr0 \
  --ide2 local-lvm:cloudinit \
  --serial0 socket --vga serial0 \
  --agent 1  
  
qm template 9001
```

```bash
qm clone 9001 101 --name test --full 1

qm disk resize 101 scsi0 16G

qm set 101 \
  --ciupgrade 1 \
  --ciuser dms --cipassword 'dms' \
  --ipconfig0 ip=192.168.178.211/24,gw=192.168.178.1

qm start 101
```


```bash
docker compose -f docker-compose.yml run --rm terraform init

docker compose -f docker-compose.yml run --rm terraform fmt -recursive

docker compose -f docker-compose.yml run --rm terraform validate

docker compose -f docker-compose.yml run --rm terraform plan
```
