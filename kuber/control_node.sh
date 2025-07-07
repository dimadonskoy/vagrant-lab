#!/usr/bin/env bash
#######################################################################
# Developed by : Dmitri Donskoy
# Purpose : Control node
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

sudo kubeadm config images pull