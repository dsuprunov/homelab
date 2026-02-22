### pve (proxmox host)

1) Create a folder for VM persistent data
    ```bash
    mkdir -p /mnt/pve/pve-data/vm-pihole
    chmod 777 /mnt/pve/pve-data/vm-pihole
    ls -ld /mnt/pve/pve-data/vm-pihole
    ```

2) Create a Directory Mapping (if it does not exist yet)
    ```bash
    pvesh create /cluster/mapping/dir \
      --id vm-pihole \
      --map node=pve,path=/mnt/pve/pve-data/vm-pihole
    ```

3) Connect VirtioFS to the VM
    ```bash
    qm shutdown 201
    qm set 201 -virtiofs0 dirid=vm-pihole,cache=auto
    qm config 201 | grep -i virtiofs
    qm start 201
    qm status 201
    ```

### vm-pihole (pihole virtual machine)

4) Mount VirtioFS
    ```bash
    sudo mkdir -p /mnt/vm-pihole
    sudo mount -t virtiofs vm-pihole /mnt/vm-pihole
    mount | grep vm-pihole
    ```

5) Enable auto-mount (systemd automount)
    ```bash
    echo 'vm-pihole /mnt/vm-pihole virtiofs nofail,x-systemd.automount 0 0' | sudo tee -a /etc/fstab
    sudo systemctl daemon-reload
    sudo umount /mnt/vm-pihole
    sudo mount -a
    mount | grep vm-pihole 
    ```

6) Make `/etc/pihole` a symlink to `/mnt/vm-pihole/etc/pihole`
    ```bash
    sudo mkdir -p /mnt/vm-pihole/etc/pihole
    sudo ln -s /mnt/vm-pihole/etc/pihole /etc/pihole
    ls -ld /etc/pihole
    ```

7) Install Pi-hole
    ```bash
    curl -sSL https://install.pi-hole.net | bash
    sudo systemctl status pihole-FTL --no-pager
    ```
