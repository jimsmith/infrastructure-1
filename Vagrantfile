

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "private_network", ip: "192.168.0.100"
  config.vm.provision :shell, path: "infrastructure/scripts/up.sh"
  config.vm.network :forwarded_port, host: 8008, guest: 8008
end