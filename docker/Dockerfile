FROM debian:13-slim

ARG USERNAME=homelab
ARG USER_UID=1000
ARG USER_GID=1000

ARG TERRAFORM_VERSION=1.15.7
ARG PACKER_VERSION=1.15.4
ARG ANSIBLE_CORE_VERSION=2.20.5
ARG KUBERNETES_PYTHON_VERSION=35.0.0
ARG KUBECTL_VERSION=1.36.2
ARG KUBEADM_VERSION=1.36.2
ARG HELM_VERSION=3.20.2
ARG K9S_VERSION=0.51.0

RUN test "$(dpkg --print-architecture)" = amd64 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      dnsutils \
      gettext-base \
      git \
      mc \
      nano \
      openssh-client \
      procps \
      python3 \
      python3-venv \
      qemu-system-x86 \
      qemu-utils \
      tmux \
      unzip \
      xorriso \
      zsh \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "${USER_GID}" "${USERNAME}" && \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /usr/bin/zsh "${USERNAME}"

# Terraform
RUN curl -fsSLo /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform -d /usr/local/bin && \
    rm /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Packer
RUN curl -fsSLo /tmp/packer_${PACKER_VERSION}_linux_amd64.zip "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" && \
    unzip /tmp/packer_${PACKER_VERSION}_linux_amd64.zip packer -d /usr/local/bin && \
    rm /tmp/packer_${PACKER_VERSION}_linux_amd64.zip

# kubectl
RUN curl -fsSLo /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod 0755 /usr/local/bin/kubectl

# kubeadm
RUN curl -fsSLo /usr/local/bin/kubeadm "https://dl.k8s.io/release/v${KUBEADM_VERSION}/bin/linux/amd64/kubeadm" && \
    chmod 0755 /usr/local/bin/kubeadm

# Helm
RUN curl -fsSLo /tmp/helm_${HELM_VERSION}_linux_amd64.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
    tar -xzf /tmp/helm_${HELM_VERSION}_linux_amd64.tar.gz -C /tmp linux-amd64/helm && \
    install -m 0755 /tmp/linux-amd64/helm /usr/local/bin/helm && \
    rm -rf /tmp/helm_${HELM_VERSION}_linux_amd64.tar.gz /tmp/linux-amd64

# k9s
RUN curl -fsSLo /tmp/k9s_${K9S_VERSION}_linux_amd64.tar.gz "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz" && \
    tar -xzf /tmp/k9s_${K9S_VERSION}_linux_amd64.tar.gz -C /tmp k9s && \
    install -m 0755 /tmp/k9s /usr/local/bin/k9s && \
    rm /tmp/k9s_${K9S_VERSION}_linux_amd64.tar.gz /tmp/k9s

RUN python3 -m venv /opt/ansible && \
    /opt/ansible/bin/python -m pip install --no-cache-dir "ansible-core==${ANSIBLE_CORE_VERSION}" "kubernetes==${KUBERNETES_PYTHON_VERSION}"

COPY requirements.yaml /tmp/ansible-requirements.yaml
RUN PYTHONUNBUFFERED=1 /opt/ansible/bin/ansible-galaxy collection install -p /usr/share/ansible/collections -r /tmp/ansible-requirements.yaml --no-deps && \
    rm /tmp/ansible-requirements.yaml

COPY --chown=${USER_UID}:${USER_GID} zshrc /home/${USERNAME}/.zshrc
RUN install -d -m 0700 -o "${USER_UID}" -g "${USER_GID}" \
      /home/${USERNAME}/.kube \
      /home/${USERNAME}/.ssh \
      /home/${USERNAME}/.config \
      /home/${USERNAME}/.cache \
      /home/${USERNAME}/.cache/packer

USER ${USERNAME}
ENV HOME=/home/${USERNAME}
ENV PATH=/opt/ansible/bin:${PATH}
WORKDIR /home/${USERNAME}

CMD ["sleep", "infinity"]
