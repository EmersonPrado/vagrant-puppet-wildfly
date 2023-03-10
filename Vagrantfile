# VM settings file
require 'yaml'
VMS = YAML.load_file('vms.yaml')

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  VMS.each do |name, confs|
    config.vm.define name do |vm|

      vm.vm.box = 'bento/centos-7'

      # VirtualBox settings
      vm.vm.provider 'virtualbox' do |virtualbox|
        virtualbox.memory = 448
        virtualbox.cpus = 1
        virtualbox.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      end

      # Network settings
      vm.vm.hostname = name
      vm.vm.network 'private_network', ip: confs[:ip]

      vm.vm.provision :shell do |shell|
        shell.name = 'Install Puppet'
        shell.path = 'bin/install_puppet.sh'
        shell.args = '5'
      end

      vm.vm.provision :puppet do |puppet|
        puppet.manifests_path = 'manifests'
        puppet.module_path = 'modules'
        puppet.hiera_config_path = 'hiera.yaml'
        puppet.working_directory = '/tmp/vagrant-puppet'
      end

    end
  end

end
