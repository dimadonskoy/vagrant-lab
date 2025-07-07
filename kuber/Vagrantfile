####### UBUNTU ARM64 ########
Vagrant.configure("2") do |config|

  config.vm.define "kube-master1" do |vm1|
    vm1.vm.box = "net9/ubuntu-24.04-arm64"
    vm1.vm.hostname = "kube-master1"
    vm1.disksize.size = '20GB'
    vm1.vm.network "private_network", ip: "192.168.55.240", mac: "08:00:27:00:00:01"
    vm1.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    vm1.vm.provision "shell", path: "disk_resize.sh"
    vm1.vm.provision "shell", path: "install_kubeadm.sh"
    vm1.vm.provision "shell", path: "control_node.sh"
  end

  config.vm.define "kube-worker1" do |vm2|
    vm2.vm.box = "net9/ubuntu-24.04-arm64"
    vm2.vm.hostname = "kube-worker1"
    vm2.disksize.size = '20GB'
    vm2.vm.network "private_network", ip: "192.168.55.243", mac: "08:00:27:00:00:02"
    vm2.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end
    vm2.vm.provision "shell", path: "install_kubeadm.sh"
  end

  config.vm.define "kube-worker2" do |vm3|
    vm3.vm.box = "net9/ubuntu-24.04-arm64"
    vm3.vm.hostname = "kube-worker2"
    vm3.disksize.size = '20GB'
    vm3.vm.network "private_network", ip: "192.168.55.244", mac: "08:00:27:00:00:03"
    vm3.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end
    vm3.vm.provision "shell", path: "install_kubeadm.sh"
  end
end

