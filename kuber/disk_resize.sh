#!/usr/bin/env bash
#######################################################################
# Developed by : Dmitri Donskoy
# Purpose : Disk resize
# Date : 27.06.2025
# Version : 0.0.1
set -o errexit
set -o nounset
set -o pipefail
#######################################################################
export DEBIAN_FRONTEND=noninteractive

# Set user home (for Vagrant or sudo)
USER_HOME="/home/${SUDO_USER:-$USER}"

# Configurable git user info
GIT_USER_EMAIL="crooper22@gmail.com"
GIT_USER_NAME="Dmitri Donskoy"

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

# --- Disk Resize Automation ---
disk_resize() {
    log "Starting disk resize automation..."
    # Install growpart if not present
    if ! command -v growpart >/dev/null 2>&1; then
        log "Installing cloud-guest-utils (for growpart)..."
        apt-get update && apt-get install -y cloud-guest-utils
    fi

    # Check if /dev/sda3 exists and is not already expanded
    DISK_DEV="/dev/sda"
    PART_NUM=3
    PART_DEV="${DISK_DEV}${PART_NUM}"
    LV_PATH="/dev/mapper/ubuntu--vg-ubuntu--lv"

    # Get disk and partition sizes
    DISK_SIZE=$(lsblk -b -n -o SIZE "$DISK_DEV" | head -n1)
    PART_SIZE=$(lsblk -b -n -o SIZE "$PART_DEV" | head -n1)

    if [ "$DISK_SIZE" -gt "$PART_SIZE" ]; then
        log "Expanding partition $PART_DEV to fill disk $DISK_DEV..."
        growpart "$DISK_DEV" "$PART_NUM"
        log "Partition $PART_DEV expanded."
    else
        log "Partition $PART_DEV already uses all available disk space."
    fi

    # Resize PV
    if pvdisplay "$PART_DEV" | grep -q "Free PE / Size *0"; then
        log "Resizing physical volume $PART_DEV..."
        pvresize "$PART_DEV"
        log "Physical volume $PART_DEV resized."
    else
        log "Physical volume $PART_DEV already uses all available space."
    fi

    # Extend LV
    if vgdisplay ubuntu-vg | grep -q "Free  PE / Size *0"; then
        log "No free space in volume group, skipping LV extend."
    else
        log "Extending logical volume $LV_PATH..."
        lvextend -l +100%FREE "$LV_PATH"
        log "Logical volume $LV_PATH extended."
    fi

    # Resize filesystem
    FS_TYPE=$(lsblk -no FSTYPE "$LV_PATH")
    if [ "$FS_TYPE" = "ext4" ]; then
        log "Resizing ext4 filesystem on $LV_PATH..."
        resize2fs "$LV_PATH"
        log "Filesystem on $LV_PATH resized."
    elif [ "$FS_TYPE" = "xfs" ]; then
        log "Resizing xfs filesystem on $LV_PATH..."
        xfs_growfs /
        log "Filesystem on $LV_PATH resized."
    else
        log "Unknown filesystem type $FS_TYPE on $LV_PATH, skipping resize."
    fi
    log "Disk resize automation completed."
}

disk_resize