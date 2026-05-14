BOX_IMAGE = "ubuntu/jammy64"

FW_FRONT_IP = "10.0.1.1"
FW_DMZ_IP = "10.0.5.1"
FW_BACK_IP = "10.0.3.1"

CLIENT_IP = "10.0.1.2"
WEBSERVER_IP = "10.0.5.2"
DATABASE_IP = "10.0.3.2"

VM_MEMORY = 1024
VM_CPUS = 1

Vagrant.configure("2") do |config|
  config.vm.box = BOX_IMAGE
  config.vm.boot_timeout = 600
  config.ssh.forward_agent = true
  config.ssh.insert_key = true

  config.vm.define "firewall" do |fw|
    fw.vm.hostname = "firewall"
    fw.vm.network "private_network", ip: FW_FRONT_IP, virtualbox__intnet: "frontend-net"
    fw.vm.network "private_network", ip: FW_DMZ_IP, virtualbox__intnet: "dmz-net"
    fw.vm.network "private_network", ip: FW_BACK_IP, virtualbox__intnet: "backend-net"
    
    fw.vm.provision "shell", inline: <<-SHELL
      mkdir -p /home/vagrant/.ssh/vagrant_keys
      cp -r /vagrant/.vagrant/machines/ /home/vagrant/.ssh/vagrant_keys/
      chown -R vagrant:vagrant /home/vagrant/.ssh/vagrant_keys/
      chmod 700 /home/vagrant/.ssh/vagrant_keys
      find /home/vagrant/.ssh/vagrant_keys -name "private_key" -exec chmod 600 {} \\;
    SHELL

    fw.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/site.yml"
      ansible.inventory_path = "ansible/inventory.ini"
      ansible.install_mode = "pip"
    end  
  end

  config.vm.define "client" do |client|
    client.vm.hostname = "client"
    client.vm.network "private_network", ip: CLIENT_IP, virtualbox__intnet: "frontend-net"
  end

  config.vm.define "webserver" do |web|
    web.vm.hostname = "webserver"
    web.vm.network "private_network", ip: WEBSERVER_IP, virtualbox__intnet: "dmz-net"
  end

  config.vm.define "database" do |db|
    db.vm.hostname = "database"
    db.vm.network "private_network", ip: DATABASE_IP, virtualbox__intnet: "backend-net"
  end
end