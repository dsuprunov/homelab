#!/usr/bin/env sh
set -eu

target_name="${1:-}"
image_version="${2:-$(date -u +%Y%m%d)}"
usage="Usage: ${0} <ubuntu_24_04|ubuntu_26_04|debian_13> [YYYYMMDD]"

if [ -z "${target_name}" ]; then
  echo "${usage}" >&2
  exit 1
fi

case "${target_name}" in
  ubuntu_24_04)
    ssh_username="ubuntu"
    source_name="qemu.ubuntu_24_04"
    artifact_name="ubuntu-24.04.qcow2"
    artifact_output_dir="artifacts/ubuntu-24.04/${image_version}"
    ;;
  ubuntu_26_04)
    ssh_username="ubuntu"
    source_name="qemu.ubuntu_26_04"
    artifact_name="ubuntu-26.04.qcow2"
    artifact_output_dir="artifacts/ubuntu-26.04/${image_version}"
    ;;
  debian_13)
    ssh_username="debian"
    source_name="qemu.debian_13"
    artifact_name="debian-13.qcow2"
    artifact_output_dir="artifacts/debian-13/${image_version}"
    ;;
  *)
    echo "Unsupported target: ${target_name}" >&2
    echo "${usage}" >&2
    exit 1
    ;;
esac

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "${script_dir}"

temporary_dir=".tmp/${target_name}-${image_version}"
cloud_init_dir="${temporary_dir}/cloud-init"
ssh_password="packer"
artifact_path="${artifact_output_dir}/${artifact_name}"

if [ -e "${artifact_output_dir}" ]; then
  echo "Artifact output already exists: ${artifact_output_dir}" >&2
  exit 1
fi

mkdir -p "${cloud_init_dir}"

export SSH_USERNAME="${ssh_username}"
export SSH_PASSWORD="${ssh_password}"
export TARGET_NAME="${target_name}"
export IMAGE_VERSION="${image_version}"

envsubst '${SSH_USERNAME} ${SSH_PASSWORD}' < cloud-init/user-data.yaml.tpl > "${cloud_init_dir}/user-data"
envsubst '${TARGET_NAME} ${IMAGE_VERSION}' < cloud-init/meta-data.yaml.tpl > "${cloud_init_dir}/meta-data"

packer init .
packer validate \
  -only="${source_name}" \
  -var "image_version=${image_version}" \
  -var "cloud_init_dir=${cloud_init_dir}" \
  -var "ssh_password=${ssh_password}" \
  .

started_at="$(date +%s)"
packer build \
  -only="${source_name}" \
  -var "image_version=${image_version}" \
  -var "cloud_init_dir=${cloud_init_dir}" \
  -var "ssh_password=${ssh_password}" \
  .
finished_at="$(date +%s)"

sha256sum "${artifact_path}" > "${artifact_path}.sha256"
echo "Artifact: ${artifact_path}"
echo "Checksum: ${artifact_path}.sha256"
echo "Elapsed seconds: $((finished_at - started_at))"
