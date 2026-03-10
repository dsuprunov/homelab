FROM debian:13-slim

ARG USERNAME=homelab
ARG HOST_UID=1000
ARG HOST_GID=1000
ARG TERRAFORM_VERSION=1.14.6

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      dnsutils \
      git \
      unzip \
      zsh \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "${HOST_GID}" "${USERNAME}" && \
    useradd --uid "${HOST_UID}" --gid "${HOST_GID}" --create-home --shell /usr/bin/zsh "${USERNAME}"

RUN curl -fsSLo /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform -d /usr/local/bin && \
    rm /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

USER ${USERNAME}

ENV HOME=/home/${USERNAME}

CMD ["zsh"]
