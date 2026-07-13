# Ansible

## Deploy

```bash
cd /homelab/ansible

ansible --version
ansible-galaxy collection list
ansible-inventory --graph

ansible -m ping all

ansible-playbook playbooks/dns.yaml --syntax-check
ansible-playbook playbooks/dns.yaml

ansible-playbook playbooks/k8s.yaml --syntax-check
ansible-playbook playbooks/k8s.yaml
```

## Inventory checks

```bash
ansible-playbook playbooks/k8s.yaml --list-hosts
ansible-playbook playbooks/k8s.yaml --list-tasks
```
