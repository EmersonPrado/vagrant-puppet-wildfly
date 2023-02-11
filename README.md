# EmersonPrado/vagrant-puppet-wildfly

### Index

1. [Description](#description)
1. [Usage](#usage)
1. [Limitations](#limitations)

## Description

This project contains a Vagrant configuration which configures a set of VMs aimed at testing [Puppet wildfly module](https://forge.puppet.com/modules/biemond/wildfly). It can be used to confirm both functionality and bugs and test specific implementations and bug solutions.

## Usage

1. Clone as usual
1. Go to cloned directory
1. Edit files to suit your needs
    1. General VM settings in `Vagrantfile`
    1. VM list and per-VM IPs in `vms.yaml`
        > Vagrant private network - VirtualBox host-only network - On top of Vagrant's mandatory NAT interface

        > IPs are optional - In their abscence, VMs get only NAT interface

        > Use IPs in range 192.168.56.2 - 192.168.56.255

    1. Puppet provisioning in `manifests/default.pp`
    1. Needed modules and their dependencies in `Puppetfile`
    1. Hiera data in `data/`
        > Follow (or edit) hierarchy defined in `hiera.yaml`

1. Install Puppet modules with `r10k puppetfile install -v`
1. Manage VMs
    - Create and provision or start existing VMs with `vagrant up`
    - Provision (again) with `vagrant provision`
    - Shut down with `vagrant halt`
    - Erase wih `vagrant destroy`
1. Enjoy the installations
    > Access the JBoss web console at &lt;IP&gt;:9990

## Limitations

- Only tested with CentOS (Vagrant box 'bento/centos-7'), Puppet 6 and Java JDK 9.0.1
- JGroups still not implemented
- Not much configurable (so far, aims very specific tests)
