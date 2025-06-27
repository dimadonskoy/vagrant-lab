#!/usr/bin/env bash

# List running VirtualBox VMs
vms=($(VBoxManage list runningvms | awk -F '"' '{print $2}'))

# Check if any VMs are running
if [ ${#vms[@]} -eq 0 ]; then
    echo "No running VMs found."
    exit 1
fi

# Display running VMs with numbers
echo "Running VMs:"
for i in "${!vms[@]}"; do
    echo "$((i+1)). ${vms[i]}"
done

echo
read -p "Enter the number of the VM to stop: " vm_index

# Validate input
if [[ "$vm_index" =~ ^[0-9]+$ ]] && [ "$vm_index" -ge 1 ] && [ "$vm_index" -le ${#vms[@]} ]; then
    vm_name="${vms[$((vm_index-1))]}"
    echo "Stopping VM: $vm_name"
    VBoxManage controlvm "$vm_name" acpipowerbutton
else
    echo "Invalid selection. Exiting."
    exit 1
fi

