# VM settings file
require 'yaml'
VMS = YAML.load_file('vms.yaml')

Vagrant.configure("2") do |config|

  VMS.each do |name, confs|
    config.vm.define name do |vm|

      vm.vm.box = confs[:box]

    end
  end

end
