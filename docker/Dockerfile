FROM debian:13-slim

ARG USERNAME=homelab
ARG HOST_UID=1000
ARG HOST_GID=1000

ARG TERRAFORM_VERSION=1.15.7
ARG ANSIBLE_CORE_VERSION=2.20.5
ARG KUBERNETES_PYTHON_VERSION=35.0.0
ARG KUBECTL_VERSION=1.36.0
ARG KUBEADM_VERSION=1.36.0
ARG HELM_VERSION=3.20.2
ARG HELM_DIFF_VERSION=3.15.6
ARG FLUX_VERSION=2.8.6
ARG K9S_VERSION=0.51.0
ARG VAULT_VERSION=2.0.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      dnsutils \
      git \
      mc \
      nano \
      openssh-client \
      python3 \
      python3-venv \
      unzip \
      procps \
      zsh \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "${HOST_GID}" "${USERNAME}" && \
    useradd --uid "${HOST_UID}" --gid "${HOST_GID}" --create-home --shell /usr/bin/zsh "${USERNAME}"

RUN curl -fsSLo /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform -d /usr/local/bin && \
    rm /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN curl -fsSLo /tmp/vault_${VAULT_VERSION}_linux_amd64.zip "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" && \
    unzip /tmp/vault_${VAULT_VERSION}_linux_amd64.zip vault -d /usr/local/bin && \
    rm /tmp/vault_${VAULT_VERSION}_linux_amd64.zip

RUN curl -fsSLo /usr/local/bin/kubeadm "https://dl.k8s.io/release/v${KUBEADM_VERSION}/bin/linux/amd64/kubeadm" && \
    chmod 0755 /usr/local/bin/kubeadm

RUN curl -fsSLo /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod 0755 /usr/local/bin/kubectl

RUN curl -fsSLo /tmp/helm_${HELM_VERSION}_linux_amd64.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
    tar -xzf /tmp/helm_${HELM_VERSION}_linux_amd64.tar.gz -C /tmp && \
    install -m 0755 /tmp/linux-amd64/helm /usr/local/bin/helm && \
    rm -rf /tmp/helm_${HELM_VERSION}_linux_amd64.tar.gz /tmp/linux-amd64

RUN HELM_PLUGINS=/usr/local/share/helm/plugins helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION}

RUN curl -fsSLo /tmp/flux_${FLUX_VERSION}_linux_amd64.tar.gz "https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz" && \
    tar -xzf /tmp/flux_${FLUX_VERSION}_linux_amd64.tar.gz -C /tmp && \
    install -m 0755 /tmp/flux /usr/local/bin/flux && \
    rm -rf /tmp/flux_${FLUX_VERSION}_linux_amd64.tar.gz /tmp/flux

RUN curl -fsSLo /tmp/k9s_${K9S_VERSION}_linux_amd64.tar.gz "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz" && \
    tar -xzf /tmp/k9s_${K9S_VERSION}_linux_amd64.tar.gz -C /tmp k9s && \
    install -m 0755 /tmp/k9s /usr/local/bin/k9s && \
    rm -rf /tmp/k9s_${K9S_VERSION}_linux_amd64.tar.gz /tmp/k9s

RUN python3 -m venv /opt/ansible && \
    /opt/ansible/bin/python -m pip install --no-cache-dir \
      "ansible-core==${ANSIBLE_CORE_VERSION}" \
      "kubernetes==${KUBERNETES_PYTHON_VERSION}"
RUN /opt/ansible/bin/ansible-galaxy collection install -p /usr/share/ansible/collections community.general
RUN /opt/ansible/bin/ansible-galaxy collection install -p /usr/share/ansible/collections ansible.posix
RUN /opt/ansible/bin/ansible-galaxy collection install -p /usr/share/ansible/collections kubernetes.core

USER ${USERNAME}

ENV HOME=/home/${USERNAME}
ENV HELM_PLUGINS=/usr/local/share/helm/plugins
ENV PATH=/opt/ansible/bin:${PATH}

CMD ["zsh"]
