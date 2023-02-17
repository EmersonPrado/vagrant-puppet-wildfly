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

sudo ss -ptln | sed -n '1p;/java/p'
# Answer should be:
State      Recv-Q Send-Q Local Address:Port               Peer Address:Port
LISTEN     0      128     [::ffff:127.0.0.1]:8443                  [::]:*                   users:(("java",pid=<PID>,fd=<FD>))
LISTEN     0      50      [::ffff:127.0.0.1]:9990                  [::]:*                   users:(("java",pid=<PID>,fd=<FD>))
LISTEN     0      128     [::ffff:127.0.0.1]:8080                  [::]:*                   users:(("java",pid=<PID>,fd=<FD>))

# Remember to close VM SSH session
exit
```

Access the [web console](http://192.168.56.4:9990/console/App.html) in your browser

- User: admin
- Pass: pass

Enter "Runtime" tab
> There should be server "Standalone Server"

Remember to close the session: Admin -> Logout -> Confirm

### Domain mode

```Shell
# In your station
vagrant up controller managed
vagrant ssh controller

# Inside VM:
systemctl status wildfly
# Answer should contain "Active: active (running)"

sudo ss -ptln | sed -n '1p;/java/p'
# Answer should be:
State      Recv-Q Send-Q Local Address:Port               Peer Address:Port
LISTEN     0      50       [::ffff:192.168.56.5]:9990                  [::]:*                   users:(("java",pid=<PID>,fd=85))
LISTEN     0      50      [::ffff:127.0.0.1]:<Port>                 [::]:*                   users:(("java",pid=<PID>,fd=18))
LISTEN     0      50       [::ffff:192.168.56.5]:9999                  [::]:*                   users:(("java",pid=<PID>,fd=76))

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

Access the [web console](http://192.168.56.5:9990/console/App.html) in your browser

- User: admin
- Pass: pass

Enter "Runtime" tab

- Hosts: there should be "managed" and "master"
- Server Groups: there should be "app-server-group", with server "app"

Remember to close the session: Admin -> Logout -> Confirm

## Limitations

- Only tested with CentOS (Vagrant box [bento/centos-7](https://app.vagrantup.com/bento/boxes/centos-7)), Puppet 6 and Java JDK 9.0.1
- JGroups still not implemented
- Not much configurable (so far, aims very specific tests)
- Might get some network domain and include in the VMs FQDNs
- Issues a warning - apparently harmless - after resource `/Stage[main]/Wildfly::Install/File[/tmp/wildfly/wildfly-<Version>.tar.gz]/ensure`:

    ```
    ==> <MV name>: Warning: Private key for '<MV FQDN>' does not exist
    ==> <MV name>: Warning: Client certificate for '<MV FQDN>' does not exist
    ```

- Issues an error - apparently harmless - in managed VM:

    ```
    ==> managed: Notice: /Stage[main]/Main/Node[__node_regexp__managed]/Wildfly::Host::Server_config[app]/Wildfly_resource[/host=managed/server-config=app]/ensure: created
    ==> managed: Error: Net::ReadTimeout
    ==> managed: Error: /Stage[main]/Main/Node[__node_regexp__managed]/Wildfly::Host::Server_config[app]/Wildfly_cli[/host=managed/server-config=app:start(blocking=true)]/executed: change from false to true failed: Net::ReadTimeout
    ```
