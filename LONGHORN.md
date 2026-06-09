# Longhorn Operations

## Install

1) Verify that the `sdb` disk is visible
```bash
ssh ubuntu@vm-k8s-worker-03

lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS

exit
```

2) Install Longhorn node packages
```bash
ssh ubuntu@vm-k8s-worker-03

sudo apt update
sudo apt install -y open-iscsi dmsetup

sudo systemctl enable --now iscsid
sudo modprobe iscsi_tcp

systemctl status iscsid --no-pager

exit
```

3) Partition, format, and mount the 32 GB `sdb` disk for Longhorn data
```bash
ssh ubuntu@vm-k8s-worker-03

sudo parted -s /dev/sdb mklabel gpt
sudo parted -s /dev/sdb mkpart primary ext4 1MiB 100%
sudo mkfs.ext4 -L longhorn-data /dev/sdb1

UUID=$(sudo blkid -s UUID -o value /dev/sdb1)
grep -q '/var/lib/longhorn' /etc/fstab \
  && echo '/var/lib/longhorn already exists in /etc/fstab, nothing added' \
  || echo "UUID=$UUID /var/lib/longhorn ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

sudo install -d -o root -g root -m 0755 /var/lib/longhorn
sudo systemctl daemon-reload
sudo mount -a

df -h /var/lib/longhorn
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS

exit
```

4) Mark `vm-k8s-worker-03` as the Longhorn data node
```bash
kubectl get nodes

kubectl label node vm-k8s-worker-03 node.longhorn.io/create-default-disk=config --overwrite

kubectl annotate node vm-k8s-worker-03 \
  node.longhorn.io/default-disks-config='[{"name":"sdb","path":"/var/lib/longhorn","allowScheduling":true}]' \
  --overwrite
```

5) Install Longhorn `v1.12.0` with Helm
```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update

helm upgrade --install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace \
  --version 1.12.0 \
  --set defaultSettings.createDefaultDiskLabeledNodes=true \
  --set defaultSettings.defaultDataPath=/var/lib/longhorn \
  --set defaultSettings.defaultReplicaCount=1 \
  --set persistence.defaultClassReplicaCount=1
```

6) Verify Longhorn pods and storage class
```bash
watch kubectl -n longhorn-system get pods -o wide
kubectl get storageclass
kubectl -n longhorn-system get settings.longhorn.io default-replica-count default-data-path create-default-disk-labeled-nodes
```

7) Open Longhorn UI
```bash
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80

http://127.0.0.1:8080
```

8) Smoke-test Longhorn PVC
```bash
kubectl create namespace longhorn-smoke-test

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: longhorn-smoke-test
  namespace: longhorn-smoke-test
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 16Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: longhorn-smoke-test
  namespace: longhorn-smoke-test
spec:
  nodeSelector:
    kubernetes.io/hostname: vm-k8s-worker-03
  restartPolicy: Never
  containers:
    - name: smoke-test
      image: busybox:1.38
      command:
        - sh
        - -c
        - echo "longhorn smoke test $(date -u +%Y-%m-%dT%H:%M:%SZ)" > /data/smoke.txt && cat /data/smoke.txt && sleep infinity
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: longhorn-smoke-test
EOF

watch kubectl -n longhorn-smoke-test get pods
kubectl -n longhorn-smoke-test wait --for=condition=Ready pod/longhorn-smoke-test --timeout=180s
kubectl -n longhorn-smoke-test logs longhorn-smoke-test
kubectl -n longhorn-smoke-test exec longhorn-smoke-test -- cat /data/smoke.txt
kubectl -n longhorn-smoke-test get pvc,pod -o wide
kubectl -n longhorn-system get volumes.longhorn.io
```

9) Cleanup smoke-test
```bash
kubectl delete namespace longhorn-smoke-test
kubectl -n longhorn-system get volumes.longhorn.io
```

## Useful Checks

```bash
helm -n longhorn-system list

kubectl -n longhorn-system get pods -o wide
kubectl -n longhorn-system get volumes.longhorn.io
kubectl -n longhorn-system get replicas.longhorn.io
kubectl -n longhorn-system get nodes.longhorn.io
```
