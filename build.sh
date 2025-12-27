#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting system configuration..."

# 1. Check if the script is running with sudo/root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)."
   exit 1
fi

# 2. Install Ansible Core
echo "Installing ansible-core..."
dnf install -y ansible-core

# 3. Install required Ansible collections
# Note: We run this as the calling user if possible, or root if required
echo "Installing Ansible collections..."
ansible-galaxy collection install community.general ansible.posix community.libvirt

ansible-playbook -i localhost, -c local add_virtualization.yml
ansible-playbook -i localhost, -c local add_network.yml
ansible-playbook -i localhost, -c local add_storage.yml

echo "Installation complete!"
