$tmp_dir = '/tmp/wildfly'
$standalone_ip = '192.168.56.4'
$controller_ip = '192.168.56.5'
$managed_ip = '192.168.56.6'

file { $tmp_dir:
  ensure => directory,
}

class { 'java':
  distribution => 'jdk',
}

$wildfly_defaults = {
  install_cache_dir => $tmp_dir,
  java_home         => '/usr',
  mgmt_user         => { username  => 'admin', password  => 'pass' },
}

# The Admin Console listens to the management interface
node /^standalone/ {
  class { 'wildfly':
    properties => {
      'jboss.bind.address.management' => $standalone_ip,
    },
    *          => $wildfly_defaults,
  }
}

node /^controller/ {
  class { 'wildfly':
    mode           => 'domain',
    host_config    => 'host-master.xml',
    properties     => {
      'jboss.bind.address.management' => $controller_ip,
    },
    *              => $wildfly_defaults,
  }
  wildfly::config::mgmt_user { 'managed':
    password => 'whatever',
  }
}

node /^managed/ {
  ensure_packages(['nmap'])
  class { 'wildfly':
    mode         => 'domain',
    host_config  => 'host-slave.xml',
    properties   => {
      'jboss.bind.address.management' => $managed_ip,
      'jboss.domain.master.address'   => $controller_ip,
    },
    secret_value => 'd2hhdGV2ZXIK',     # Base64 encoding for 'whatever'
    *            => $wildfly_defaults,
  }
}
