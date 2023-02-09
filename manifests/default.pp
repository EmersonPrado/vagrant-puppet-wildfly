$tmp_dir = '/tmp/wildfly'

file { $tmp_dir:
  ensure => directory,
}

class { 'java':
  distribution => 'jdk',
}

$wildfly_defaults = {
  install_cache_dir => $tmp_dir,
  java_home         => '/usr',
}

node /^standalone/ {
  class { 'wildfly':
    * => $wildfly_defaults,
  }
}

node /^controller/ {
  class { 'wildfly':
    mode        => 'domain',
    host_config => 'host-master.xml',
    *           => $wildfly_defaults,
  }
}

node /^managed/ {
  class { 'wildfly':
    mode        => 'domain',
    host_config => 'host-slave.xml',
    *           => $wildfly_defaults,
  }
}
