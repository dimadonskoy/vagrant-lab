vagrant box add kube-master1 ./kube-master1.box
vagrant box add kube-master1 ./kube-worker1.box
vagrant box add kube-master1 ./kube-worker2.box

vagrant init kube-master1
vagrant init kube-worker1
vagrant init kube-worker2
vagrant up
