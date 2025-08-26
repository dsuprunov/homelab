```bash
Host 192.168.178.201
  User root
  IdentityFile ~/.ssh/homelab-dsuprunov-ed25519
  IdentitiesOnly yes
  StrictHostKeyChecking no
  UserKnownHostsFile NUL
  GlobalKnownHostsFile NUL

Host 192.168.178.2??
  User dms
  IdentityFile ~/.ssh/homelab-dsuprunov-ed25519
  IdentitiesOnly yes
  StrictHostKeyChecking no
  UserKnownHostsFile NUL
  GlobalKnownHostsFile NUL
```