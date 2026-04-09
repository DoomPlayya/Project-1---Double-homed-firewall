config.vm.define "firewall" do |fw|
fw.vm.network "private_network",
ip: "10.0.1.1",
virtualbox_intnet: "frontend-net"
fw.vm.network "private_network",
ip: "10.0.2.1",
virtualbox_intnet: "dmz-net"
fw.vm.network "private_network",
ip: "10.0.3.1",
virtualbox_intnet: "backend-net"
end
config.vm-define "client" do |cl|
cl.vm.network "private_network",
ip: "10.0.1.2",
virtualbox_intnet: "frontend-net"
end
config.vm.define "webserver" do |web|
web.vm.network "private_network",
ip: "10.0.2.2",
virtualbox_intnet: "dmz-net"
end
config.vm.define "database" do |db|
db.vm.network "private_network",
ip: "10.0.3.2",
virtualbox_intnet: "backend-net"
end
