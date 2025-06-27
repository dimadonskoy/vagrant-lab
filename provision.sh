#!/usr/bin/env bash
#######################################################################
# Developed by : Dmitri Donskoy
# Purpose : Install my environment GLOBAL CONFIGURATION
# Date : 15.02.2025
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

# Docker installation
install_docker() {
    log "Uninstall all conflicting Docker packages..."
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove -y $pkg || true; done
    log "Installing Docker..."
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    log "Docker installation completed."
}

# Install needed software
install_software() {
    log "Installing software..."
    install_docker
    apt-get install -y git nginx vim python3 python3-pip
    log "Software installation completed."
}

# Install python libraries
python_libs=("python3-flask" "python3-flask-mail" "python3-requests" "python3-netifaces" "python3-paramiko")
install_python_libs() {
    log "Installing Python libraries..."
    for lib in "${python_libs[@]}"; do
        apt-get install -y "$lib"
    done
    log "Python libraries installation completed."
}

# Configure vim
configure_vim() {
    log "Configuring Vim..."
    VIMRC="$USER_HOME/.vimrc"
    touch "$VIMRC"
    for setting in \
        "set number" \
        "syntax enable" \
        "set ts=4" \
        "set autoindent" \
        "set expandtab" \
        "set shiftwidth=4" \
        "set cursorline" \
        "set showmatch"; do
        grep -qxF "$setting" "$VIMRC" || echo "$setting" >> "$VIMRC"
    done
    log "Vim configuration completed."
}

# Add aliases and prompt to .bashrc
set_alias() {
    log "Adding aliases and prompt to .bashrc..."
    BASHRC="$USER_HOME/.bashrc"
    touch "$BASHRC"
    # Aliases
    grep -qxF "alias update='sudo apt-get update && sudo apt-get upgrade -y'" "$BASHRC" || echo "alias update='sudo apt-get update && sudo apt-get upgrade -y'" >> "$BASHRC"
    grep -qxF "alias myip='ip -o -4 addr show | awk \"{print \\\$2, \\\$4}\"'" "$BASHRC" || echo "alias myip='ip -o -4 addr show | awk \"{print \\\$2, \\\$4}\"'" >> "$BASHRC"
    grep -qxF "alias gateway='ip r | awk \"/default/ {print \\\$3}\"'" "$BASHRC" || echo "alias gateway='ip r | awk \"/default/ {print \\\$3}\"'" >> "$BASHRC"
    # Prompt
    PROMPT_FUNC='parse_git_branch() {\n    git branch 2>/dev/null | sed -n "/\\* /s///p"\n}\n\nexport PS1="\\[\\e[32m\\]\\u@\\h \\[\\e[34m\\]\\w\\[\\e[33m\\] \\$(parse_git_branch)\\[\\e[0m\\] $ "'
    grep -qxF "parse_git_branch() {" "$BASHRC" || echo -e "$PROMPT_FUNC" >> "$BASHRC"
    log "Aliases and prompt added to .bashrc."
}

# Set git config
set_git_config() {
    log "Setting git configuration..."
    git config --global user.email "$GIT_USER_EMAIL"
    git config --global user.name "$GIT_USER_NAME"
    log "Git configuration completed."
}

# Main execution
update_ubuntu
install_software
install_python_libs
configure_vim
set_alias
set_git_config