#!/usr/bin/env sh
set -eu

sudo mkdir -p /etc/default/grub.d
printf '%s\n' 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX net.ifnames=0 biosdevname=0"' |
  sudo tee /etc/default/grub.d/99-network-interface-names.cfg >/dev/null
sudo update-grub
