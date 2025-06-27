####### UBUNTU ARM64 ########
Vagrant.configure("2") do |config|
  # Define the first VM
  config.vm.define "ubuntu-arm64" do |vm1|
    vm1.vm.box = "net9/ubuntu-24.04-arm64"
    vm1.vm.hostname = "ubuntu-test"
    vm1.disksize.size = '20GB'
    vm1.vm.network "private_network", ip: "192.168.55.245"
    vm1.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 1
    end

    # Provision with external shell script to install software
    vm1.vm.provision "shell", path: "provision.sh"
  end
end

