# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.synced_folder ".", "/vagrant", type: "rsync",
    rsync__args: ["--verbose", "--archive", "--delete", "-z", "--copy-links"],
    rsync__exclude: [
      ".meteor/local/",
      ".git/",
      ".npm/",
      ".build/",
      "node_modules/"
    ]

  # expose port 3000 for Meteor
  config.vm.network :forwarded_port,  guest: 3000,    host: 3000

  # expose port 5000 for Meteor Testing Server
  config.vm.network :forwarded_port,  guest: 5000,    host: 5000

  # expose port 9200 for elasticsearch
 config.vm.network :forwarded_port,  guest: 9200,    host: 9200

  # run the install script for dependencies
  config.vm.provision :shell, :path => "scripts/bootstrap.sh"
end
