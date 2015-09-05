class profiles::mysql {
  require apt

  $hostname        = hiera('mysql::hostname')
  $username        = hiera('mysql::username')
  $password        = hiera('mysql::password')
  $database        = hiera('mysql::database')

  # Install mysql
  package { 'mysql-server':
    ensure => present
  }

  # Run mysql
  service { 'mysql':
    ensure  => running,
    require => Package['mysql-server'],
  }

  # Use a custom mysql configuration file
  file { '/etc/mysql/my.cnf':
    content => template('profiles/mysql/mysql.cnf.erb'),
    require => Package['mysql-server'],
    notify  => Service['mysql'],
  }

  # We set the root password here
  exec { 'set-mysql-password':
    unless  => "mysqladmin -h ${hostname} -u${username} -p${password} status",
    command => "mysqladmin -h ${hostname} -u${username} password ${password}",
    path    => ['/bin', '/usr/bin'],
    require => Service['mysql']
  }
}