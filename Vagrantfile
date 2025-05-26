Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    vb.cpus = 1
  end

  config.vm.define "firewall" do |firewall|
    firewall.vm.hostname = "firewall"
    firewall.vm.network "private_network", ip: "192.168.100.2", virtualbox__intnet: "dmz"
    firewall.vm.network "private_network", ip: "192.168.50.2", virtualbox__intnet: "lan"
    firewall.vm.network "private_network", ip: "192.168.200.2", virtualbox__intnet: "attacker_net"
    firewall.vm.provision "shell", path: "firewall.sh"
  end

  config.vm.define "dmz" do |dmz|
    dmz.vm.hostname = "dmz"
    dmz.vm.network "private_network", ip: "192.168.100.10", virtualbox__intnet: "dmz"
    dmz.vm.provision "shell", path: "dmz.sh"
  end

  config.vm.define "lan" do |lan|
    lan.vm.hostname = "lan"
    lan.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "lan"
    lan.vm.provision "shell", path: "lan.sh"
  end

  config.vm.define "attacker" do |attacker|
    attacker.vm.hostname = "attacker"
    attacker.vm.network "private_network", ip: "192.168.200.20", virtualbox__intnet: "attacker_net"
    attacker.vm.provision "shell", path: "atk.sh"
  end
end