### vm-k8s-control-02

```bash
ssh ubuntu@192.168.178.225

#
# Settings
#
K8S_VERSION="v1.34"
PAUSE_VERSION="3.10.1"

#
# VM agent (QEMU Guest Agent)
#
sudo apt-get update -y
sudo apt-get install -y qemu-guest-agent
sudo systemctl start qemu-guest-agent
```