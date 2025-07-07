#!/usr/bin/env bash
#######################################################################
# Developed by : Dmitri Donskoy
# Purpose : Restore Vagrant boxes
# Date : 07.07.2025
# Version : 0.0.1
set -o errexit
set -o nounset
set -o pipefail
#######################################################################
set -e
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

# Add Vagrant boxes
if [ -f ./kube-master1.box ]; then
  echo "Adding kube-master1 box..."
  vagrant box add kube-master1 ./kube-master1.box || true
else
  echo "kube-master1.box not found!"
fi

if [ -f ./kube-worker1.box ]; then
  echo "Adding kube-worker1 box..."
  vagrant box add kube-master1 ./kube-worker1.box || true
else
  echo "kube-worker1.box not found!"
fi

if [ -f ./kube-worker2.box ]; then
  echo "Adding kube-worker2 box..."
  vagrant box add kube-master1 ./kube-worker2.box || true
else
  echo "kube-worker2.box not found!"
fi

echo "Initializing Vagrant VMs..."
vagrant init kube-master1 || true
vagrant init kube-worker1 || true
vagrant init kube-worker2 || true

echo "Bringing up Vagrant VMs..."
vagrant up

echo "Restore complete." 