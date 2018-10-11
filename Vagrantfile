

Vagrant.configure("2") do |config|
  # Setup virtual machine box. This VM configuration code is always executed.
  config.vm.define "extractor" do |extractor|
    extractor.vm.box = "bento/ubuntu-16.04"
    extractor.vm.box_url = "bento/ubuntu-16.04"
    extractor.vm.network "private_network", ip: "192.168.254.10"
    extractor.vm.network "public_network"
    # extractor.vm.network :forwarded_port, :host => 4243, :guest => 4243
    extractor.vm.network :forwarded_port, :host => 8000, :guest => 54321
    extractor.vm.synced_folder "~/thuuz/extractor", "/home/vagrant/extractor"
    extractor.vm.synced_folder "~/Documents/reelz_base/", "/home/vagrant/reelz_base"
  
    extractor.vm.provision "shell", path: "vagrant/provision.sh"
  end
end
