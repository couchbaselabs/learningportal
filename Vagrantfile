# -*- mode: ruby -*-
# vi: set ft=ruby :
MIRROR = "http://packages.couchbase.com/releases/2.0.0-developer-preview-4"
VERSION = "couchbase-server-community_x86_64_2.0.0-dev-preview-4.deb"

# Vagrant: http://vagrantup.com
Vagrant::Config.run do |config|

  # Use 64bit Ubuntu Lucid 10.04
  config.vm.box = "lucid64.couchbase-2.0.0.dp4.722"
  # config.vm.box_url = "http://files.vagrantup.com/lucid64.box"
  config.vm.box_url = "http://libcouchbase.s3.amazonaws.com/lucid64.couchbase-2.0.0.dp4.722.box"

  # Set RAM to 1024mb 
  config.vm.customize ["modifyvm", :id, "--memory", 1024]

  # Install Couchbase
  # config.vm.provision :shell, :inline => INSTALLER

  # Forward port for couchbase admin UI
  #   open http://localhost:8091
  config.vm.forward_port 8091, 8091

  # Forward ports for couchbase client
  #   http://www.couchbase.com/docs/couchbase-manual-2.0/couchbase-network-ports.html
  config.vm.forward_port 8092, 8092
  config.vm.forward_port 11211, 11211
  config.vm.forward_port 11210, 11210
end

# (stupid) Simple Couchbase Installer
INSTALLER = <<-SRC
echo wget #{VERSION}
wget -q #{MIRROR}/#{VERSION}
echo install #{VERSION}
sudo dpkg -i #{VERSION}
SRC