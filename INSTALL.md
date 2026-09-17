# Homelab

The current image and Packer templates target Linux x86-64.

Container DNS uses the infrastructure CoreDNS server at `192.168.178.206`.
The fallback `1.1.1.1` allows public downloads before CoreDNS is deployed.

Names under `home.arpa` require the CoreDNS VM to be running.

## Setup

```bash
install -d -m 700 ~/.homelab/kube ~/.homelab/ssh
```

## Environment

```bash
cd ~/git-homelab

eval "$(ssh-agent -s)"; ssh-add ~/.ssh/homelab-ed25519

HOST_UID="$(id -u)" HOST_GID="$(id -g)" docker compose -f docker/compose.yaml up -d --build

docker compose -f docker/compose.yaml exec homelab zsh

docker compose -f docker/compose.yaml down
```

## Workflow

1. Build the image versions referenced by `terraform/00-vm-templates/images.auto.tfvars`:

   ```bash
   cd ~/git-homelab
   
   sh packer/build.sh ubuntu_26_04 20260916
   sh packer/build.sh debian_13 20260916
   ```

2. Create the VM templates:

   ```bash
   cd ~/git-homelab/terraform/00-vm-templates
   
   terraform init
   terraform validate
   terraform fmt
   terraform plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
   terraform -chdir="$HOME/git-homelab/terraform/00-vm-templates" apply terraform.tfplan
   ```

3. Create and deploy the infrastructure VMs:

   ```bash
   cd ~/git-homelab/terraform/10-bootstrap

   terraform init
   terraform validate
   terraform fmt
   terraform plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
   terraform -chdir="$HOME/git-homelab/terraform/10-bootstrap" apply terraform.tfplan

   cd ~/git-homelab/ansible
   
   ansible-playbook playbooks/dns.yaml

   dig @192.168.178.206 vm-coredns.home.arpa
   dig @192.168.178.206 -x 192.168.178.206
   dig @192.168.178.206 kubernetes.io
   ```

4. Create and deploy core services

   ```bash
   cd ~/git-homelab/terraform/20-core-services
   
   terraform init
   terraform validate
   terraform fmt
   terraform plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
   terraform -chdir="$HOME/git-homelab/terraform/20-core-services" apply terraform.tfplan
   ```

5. Create and deploy the Kubernetes VMs:

   ```bash
   cd ~/git-homelab/terraform/30-kubeadm

   terraform init
   terraform validate
   terraform fmt
   terraform plan -var-file=../credentials.auto.tfvars -out terraform.tfplan
   terraform -chdir="$HOME/git-homelab/terraform/30-kubeadm" apply terraform.tfplan

   cd ~/git-homelab/ansible
   
   ansible-playbook playbooks/k8s.yaml
   
   kubectl get nodes
   kubectl get pods -A
   ```

6. Destroy VMs:

   ```bash
   cd ~/git-homelab/terraform

   terraform -chdir=90-sandbox plan -destroy -var-file=../credentials.auto.tfvars -out terraform.tfplan
   terraform -chdir=90-sandbox apply terraform.tfplan

   terraform -chdir=30-kubeadm plan -destroy -var-file=../credentials.auto.tfvars -out terraform.tfplan
   terraform -chdir=30-kubeadm apply terraform.tfplan

   terraform -chdir=20-core-services plan -destroy -var-file=../credentials.auto.tfvars -out terraform.tfplan
   terraform -chdir=20-core-services apply terraform.tfplan

   terraform -chdir=10-bootstrap plan -destroy -var-file=../credentials.auto.tfvars -out terraform.tfplan
   terraform -chdir=10-bootstrap apply terraform.tfplan

   terraform -chdir=00-vm-templates plan -destroy -var-file=../credentials.auto.tfvars -out terraform.tfplan
   terraform -chdir=00-vm-templates apply terraform.tfplan
   ```
