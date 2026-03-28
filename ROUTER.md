```text
```

```bash
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/60-ip-forwarding.conf
sudo sysctl --system
sudo sysctl net.ipv4.ip_forward
```