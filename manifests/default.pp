$tmp_dir = '/tmp/wildfly'

file { $tmp_dir:
  ensure => directory,
}

class { 'java':
  distribution => 'jdk',
}

class { 'wildfly':
  install_cache_dir => $tmp_dir,
  java_home         => '/usr',
}
