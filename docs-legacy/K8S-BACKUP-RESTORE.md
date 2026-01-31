```bash
#
# Backup 
#
kubectl get nodes -o wide

kubectl -n longhorn-system get pods
kubectl -n longhorn-system get pods | egrep -v 'Running|Completed|NAME'

kubectl get volumes.longhorn.io -A # STATE=attached; ROBUSTNESS=healthy

pvesm status

for VM in 227 228 224; do
  vzdump ${VM} \
    --mode stop \
    --storage local \
    --compress zstd \
    --notes-template "{{guestname}} cold-stop $(date -Iseconds) vmid={{vmid}}" \
    --prune-backups keep-last=7
done

for f in /var/lib/vz/dump/vzdump-qemu-{224,227,228}-*.vma.zst; do
  zstd -t "$f" || { echo "ZSTD FAIL: $f"; exit 1; }
done

for f in /var/lib/vz/dump/vzdump-qemu-{224,227,228}-*.vma.zst; do
  echo "Verifying $f"
  zstdcat "$f" | vma verify -v - || { echo "VMA FAIL: $f"; exit 1; }
done

#
# Restore
#
ls -lh /var/lib/vz/dump/vzdump-qemu-{224,227,228}-*.vma.zst

for VM in 224 227 228; do
   qm stop ${VM}
done

qmrestore /var/lib/vz/dump/vzdump-qemu-227-2025_11_07-09_49_08.vma.zst 227 --storage local-lvm --force 1
qmrestore /var/lib/vz/dump/vzdump-qemu-228-2025_11_07-09_51_41.vma.zst 228 --storage local-lvm --force 1
qmrestore /var/lib/vz/dump/vzdump-qemu-224-2025_11_07-09_54_17.vma.zst 224 --storage local-lvm --force 1

for VM in 224 227 228; do
  qm start ${VM}
done
```