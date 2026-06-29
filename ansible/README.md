# Ansible

## Deploy

```bash
cd /homelab/ansible

ansible --version
ansible-galaxy collection list
ansible-inventory --graph

ansible -m ping vms

ansible-playbook playbooks/dns.yaml --syntax-check
ansible-playbook playbooks/dns.yaml

ansible-playbook playbooks/k8s.yaml --syntax-check
ansible-playbook playbooks/k8s.yaml

ansible-playbook playbooks/longhorn.yaml --syntax-check
ansible-playbook playbooks/longhorn.yaml
```
