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
  require           => [File[$tmp_dir], Class['java']],
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
      'jboss.management.http.port'    => '9990',        # Needed for wildfly::resource below
    },
    external_facts => true,
    *              => $wildfly_defaults,
  }
  wildfly::domain::server_group { ['main-server-group', 'other-server-group']:
    ensure => absent,
  }
  wildfly::domain::server_group { 'app-server-group':
    profile              => 'full-ha',
    socket_binding_group => 'full-ha-sockets',
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
  wildfly::host::server_config { ['server-one', 'server-two']:
    ensure => absent,
    before => Class['wildfly::setup'],
  }
  wildfly::host::server_config { 'app':
    server_group => 'app-server-group',
    hostname     => 'managed',
    username     => 'managed',
    password     => 'whatever',
  }
}
