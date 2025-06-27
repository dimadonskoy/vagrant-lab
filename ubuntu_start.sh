#!/usr/bin/env bash

# List available VirtualBox VMs
vms=($(VBoxManage list vms | awk -F '"' '{print $2}'))

# Check if any VMs exist
if [ ${#vms[@]} -eq 0 ]; then
    echo "No VMs found."
    exit 1
fi

# Display VMs with numbers
echo "Available VMs:"
for i in "${!vms[@]}"; do
    echo "$((i+1)). ${vms[i]}"
done

echo
read -p "Enter the number of the VM to start: " vm_index

# Validate input
if [[ "$vm_index" =~ ^[0-9]+$ ]] && [ "$vm_index" -ge 1 ] && [ "$vm_index" -le ${#vms[@]} ]; then
    vm_name="${vms[$((vm_index-1))]}"
    echo "Starting VM: $vm_name"
    VBoxManage startvm "$vm_name" --type headless
else
    echo "Invalid selection. Exiting."
    exit 1
fi

cd /Users/crooper/vagrant-project ; sudo vagrant ssh
