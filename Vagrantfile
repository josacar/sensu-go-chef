# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure('2') do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = 'bento/debian-10'

  # Set the version of chef to install using the vagrant-omnibus plugin
  # NOTE: You will need to install the vagrant-omnibus plugin:
  #
  #   $ vagrant plugin install vagrant-omnibus
  #
  # if Vagrant.has_plugin?('vagrant-omnibus')
  #   config.omnibus.chef_version = '15.9.17'
  # end

  config.vm.synced_folder('.', '/vagrant_data', type: 'nfs', nfs_version: 3)

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false

    # Customize the amount of memory on the VM:
    vb.memory = '512'
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  # View the documentation for the provider you're using for more
  # information on available options.

  # The path to the Berksfile to use with Vagrant Berkshelf
  config.berkshelf.berksfile_path = './Berksfile'

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  # An array of symbols representing groups of cookbook described in the Vagrantfile # to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []

  # config.vm.provision :chef_solo do |chef|
  #   chef.install = true
  #   chef.version = '15.9.17'
  #   chef.arguments = '--chef-license accept'
  #   chef.data_bags_path = 'data_bags'
  #   chef.json = {}

  #   chef.run_list = [
  #     'recipe[sensu-custom]'
  #   ]
  # end

  config.vm.define :client do |client|
    client.vm.network :private_network, ip: '192.168.50.4'
    client.vm.hostname = 'sensu-client'

    client.vm.provision :chef_solo do |chef|
      chef.install = true
      chef.version = '15.9.17'
      chef.arguments = '--chef-license accept'
      chef.data_bags_path = 'data_bags'
      chef.json = {}

      chef.run_list = [
        'recipe[sensu-custom::client]'
      ]
    end
  end

  config.vm.define :server, primary: true do |server|
    server.vm.network :private_network, ip: '192.168.5.2'
    server.vm.hostname = 'sensu-server'

    server.vm.provision :chef_solo do |chef|
      chef.install = true
      chef.version = '15.9.17'
      chef.arguments = '--chef-license accept'
      chef.data_bags_path = 'data_bags'
      chef.json = {}

      chef.run_list = [
        'recipe[sensu-custom::server]'
      ]
    end
  end
end
