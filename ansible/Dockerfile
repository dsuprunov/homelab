ARG PYTHON_VERSION=3.14
FROM python:${PYTHON_VERSION}-slim

ARG ANSIBLE_CORE_VERSION=2.20.2

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openssh-client \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir "ansible-core==${ANSIBLE_CORE_VERSION}"

RUN ansible-galaxy collection install community.general && \
    ansible-galaxy collection install kubernetes.core

RUN ansible --version
