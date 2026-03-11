FROM debian:13-slim

ARG USERNAME=homelab
ARG HOST_UID=1000
ARG HOST_GID=1000
ARG ANSIBLE_CORE_VERSION=2.20.2
ARG KUBECTL_VERSION=1.34.1
ARG TERRAFORM_VERSION=1.14.6

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      dnsutils \
      git \
      openssh-client \
      python3 \
      python3-venv \
      unzip \
      zsh \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "${HOST_GID}" "${USERNAME}" && \
    useradd --uid "${HOST_UID}" --gid "${HOST_GID}" --create-home --shell /usr/bin/zsh "${USERNAME}"

RUN curl -fsSLo /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform -d /usr/local/bin && \
    rm /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN curl -fsSLo /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod 0755 /usr/local/bin/kubectl

RUN python3 -m venv /opt/ansible && \
    /opt/ansible/bin/python -m pip install --no-cache-dir "ansible-core==${ANSIBLE_CORE_VERSION}" && \
    /opt/ansible/bin/ansible-galaxy collection install -p /usr/share/ansible/collections community.general kubernetes.core

USER ${USERNAME}

ENV HOME=/home/${USERNAME}
ENV PATH=/opt/ansible/bin:${PATH}

CMD ["zsh"]
