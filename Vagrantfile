# VM settings file
require 'yaml'
VMS = YAML.load_file('vms.yaml')

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  VMS.each do |name, confs|
    config.vm.define name do |vm|

      vm.vm.box = confs[:box]

    end
  end

end
