# Copied from docker git at https://github.com/dotcloud/docker.git
# This sets up a vagrant ubuntu precise box using virtualbox.
# Can also be used to launch AWS image.
# Simply run "vagrant up" to get everything setup locally.
# The file is meant to install docker by default
# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  # Setup virtual machine box. This VM configuration code is always executed.
  config.vm.define "extractor" do |extractor|
    extractor.vm.box = "bento/ubuntu-16.04"
    extractor.vm.box_url = "bento/ubuntu-16.04"
    extractor.vm.network "private_network", ip: "192.168.1.2"
    extractor.vm.network "public_network"
    # extractor.vm.network :forwarded_port, :host => 4243, :guest => 4243
    # extractor.vm.network :forwarded_port, :host => 8888, :guest => 3333
    extractor.vm.synced_folder "~/thuuz/extractor", "/home/vagrant/extractor"
  
    extractor.vm.provision "shell", path: "vagrant/provision.sh"
  end
end
