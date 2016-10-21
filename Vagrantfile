Vagrant.require_version ">= 1.8.4"
Vagrant.configure("2") do |config|

    #
    # define master node
    #
    config.vm.define "master", primary: true do |box|
        box.vm.box = "ubuntu/xenial64"
        box.vm.provider :virtualbox do |v|
            v.memory = 1024
            v.cpus = 1
        end

        box.vm.hostname = "master"
        box.vm.network "private_network", ip: "192.168.50.2"
        box.vm.provision "shell", path: "bootstrap.sh"
    end

    #
    # define slave-1 node
    #
    config.vm.define "slave1" do |box|
        box.vm.box = "ubuntu/xenial64"
        box.vm.provider :virtualbox do |v|
            v.memory = 2048
            v.cpus = 1
        end

        box.vm.hostname = "slave1"
        box.vm.network "private_network", ip: "192.168.50.11"
        box.vm.provision "shell", path: "bootstrap.sh"
    end

    #
    # define slave-2 node
    #
    config.vm.define "slave2" do |box|
        box.vm.box = "ubuntu/xenial64"
        box.vm.provider :virtualbox do |v|
            v.memory = 1024
            v.cpus = 1
        end

        box.vm.hostname = "slave2"
        box.vm.network "private_network", ip: "192.168.50.12"
        box.vm.provision "shell", path: "bootstrap.sh"
    end

end
