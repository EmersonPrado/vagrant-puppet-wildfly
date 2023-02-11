# EmersonPrado/vagrant-puppet-wildfly

### Index

1. [Description](#description)
1. [Usage](#usage)
1. [Validation](#validation)
    1. [Standalone mode](#standalone-mode)
    1. [Domain mode](#domain-mode)
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

## Validation

### Standalone mode

```Shell
# In your station
vagrant up standalone
vagrant ssh standalone

# Inside VM:
systemctl status wildfly
# Answer should contain "Active: active (running)"

sudo netstat -ptln | sed -n '1,2p;/java/p'
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp6       0      0 192.168.56.4:9990       :::*                    LISTEN      <PID>/java
tcp6       0      0 127.0.0.1:8080          :::*                    LISTEN      <PID>/java

# Remember to close VM SSH session
exit
```

Access the [web console](http://192.168.56.4:9990/console/App.html) in your browser

- User: admin
- Pass: pass

Enter "Runtime" tab
> There should be server "Standalone Server"

### Domain mode

```Shell
# In your station
vagrant up controller managed
vagrant ssh controller

# Inside VM:
systemctl status wildfly
# Answer should contain "Active: active (running)"

sudo netstat -ptln | sed -n '1,2p;/java/p'
# Answer should be:
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp6       0      0 192.168.56.4:9990       :::*                    LISTEN      <PID>/java
tcp6       0      0 127.0.0.1:8080          :::*                    LISTEN      <PID>/java

# Remember to close VM SSH session
exit

# In your station
vagrant ssh managed

# Inside VM:
systemctl status wildfly
# Answer should contain "Active: active (running)"

nmap -p9990,9999 192.168.56.5
# Answer should contain:
PORT     STATE SERVICE
9990/tcp open  osm-appsrvr
9999/tcp open  abyss

# Remember to close VM SSH session
exit
```

## Limitations

- Only tested with CentOS (Vagrant box 'bento/centos-7'), Puppet 6 and Java JDK 9.0.1
- JGroups still not implemented
- Not much configurable (so far, aims very specific tests)
