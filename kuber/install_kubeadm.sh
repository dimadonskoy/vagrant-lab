#!/usr/bin/env bash
#######################################################################
# Developed by : Dmitri Donskoy
# Purpose : Install kubeadm
# Date : 07.07.2025
# Version : 0.0.1
set -o errexit
set -o nounset
set -o pipefail
#######################################################################
set -eux
export DEBIAN_FRONTEND=noninteractive

# Check if user is root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Create LOGS directory if not exist
LOGDIR="$HOME/LOGS"
if [ ! -d "$LOGDIR" ]; then
    echo "LOGS directory does not exist. Creating LOGS directory..."
    mkdir -p "$LOGDIR"
fi

LOGFILE="$LOGDIR/global_env_config.log"

# Timestamp function for logs
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

# Update and upgrade the system
# Update ubuntu
update_ubuntu() {
    log "Updating Ubuntu..."
    if ! apt-get update; then
        log "apt-get update failed." >&2
        return 1
    fi
    if ! apt-get upgrade -y; then
        log "apt-get upgrade failed." >&2
        return 1
    fi
    if ! apt-get autoremove -y; then
        log "apt-get autoremove failed." >&2
        return 1
    fi
    if ! apt-get autoclean -y; then
        log "apt-get autoclean failed." >&2
        return 1
    fi
    log "Ubuntu update completed."
}

update_ubuntu


# Install common utilities
sudo apt-get install -y curl wget git vim net-tools apt-transport-https ca-certificates software-properties-common

# Install containerd
sudo apt-get install -y containerd

# Create containerd config directory if it doesn't exist
sudo mkdir -p /etc/containerd

# Generate default containerd config
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Update sandbox_image and SystemdCgroup in config.toml
sudo sed -i 's|^\(\s*sandbox_image = \).*|\1"registry.k8s.io/pause:3.9"|' /etc/containerd/config.toml
sudo sed -i 's/^\(\s*SystemdCgroup = \).*$/\1true/' /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd.service

# Configure sysctl for Kubernetes
sudo tee /etc/sysctl.d/99-k8s-cri.conf > /dev/null <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF

sudo sysctl --system

# Load kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

echo -e 'overlay\nbr_netfilter' | sudo tee /etc/modules-load.d/k8s.conf

# Switch to iptables-legacy if available
if update-alternatives --list iptables | grep -q iptables-legacy; then
  sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
fi

# Disable swap
sudo swapoff -a
# Comment out swap in /etc/fstab
sudo sed -i.bak '/\sswap\s/s/^/#/' /etc/fstab

# Disable apparmor profiles for runc and crun if they exist
if [ -f /etc/apparmor.d/runc ]; then
  sudo apparmor_parser -R /etc/apparmor.d/runc || true
  sudo mkdir -p /etc/apparmor.d/disable
  sudo ln -sf /etc/apparmor.d/runc /etc/apparmor.d/disable/
fi
if [ -f /etc/apparmor.d/crun ]; then
  sudo apparmor_parser -R /etc/apparmor.d/crun || true
  sudo mkdir -p /etc/apparmor.d/disable
  sudo ln -sf /etc/apparmor.d/crun /etc/apparmor.d/disable/
fi

# Add Kubernetes apt repository and install kubeadm, kubelet, kubectl
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor --batch --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt-get install -y kubeadm kubelet kubectl

# Install haveged
sudo apt-get update
sudo apt-get install -y haveged
sudo systemctl start haveged

# Print completion message
echo "Provisioning complete!"

export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y openssh-server

# Remove package manager locks
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/lib/apt/lists/lock 


# Install SSH public key
install_ssh_key() {
    log "Installing SSH public key..."
    
    # Your public key
    PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtN4mKVEgWq/OI6OEDK8nZYv04MuEHyEDJGXO5o+f2L crooper@Dmitris-MBP.lan"
    
    # Create .ssh directory if it doesn't exist
    SSH_DIR="$(eval echo ~${SUDO_USER:-$USER})/.ssh"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    
    # Add public key to authorized_keys
    AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
    touch "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
    
    # Check if key already exists to avoid duplicates
    if ! grep -q "$PUBLIC_KEY" "$AUTHORIZED_KEYS"; then
        echo "$PUBLIC_KEY" >> "$AUTHORIZED_KEYS"
        log "SSH public key added to authorized_keys"
    else
        log "SSH public key already exists in authorized_keys"
    fi
    
    # Set proper ownership
    chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" "$SSH_DIR"
    
    log "SSH key installation completed."
}

install_ssh_key

# Disable IPv6 system-wide

disable_ipv6() {
    log "Disabling IPv6..."
    # Disable IPv6 at runtime
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
    sysctl -w net.ipv6.conf.lo.disable_ipv6=1
    # Persist IPv6 disable across reboots
    echo 'net.ipv6.conf.all.disable_ipv6 = 1' | tee -a /etc/sysctl.conf
    echo 'net.ipv6.conf.default.disable_ipv6 = 1' | tee -a /etc/sysctl.conf
    echo 'net.ipv6.conf.lo.disable_ipv6 = 1' | tee -a /etc/sysctl.conf
    sysctl -p
    log "IPv6 disabled."
}

disable_ipv6