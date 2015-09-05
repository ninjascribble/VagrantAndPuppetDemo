class profiles::phpmyadmin {
  require apt

  $port             = hiera('phpmyadmin::port')
  $root_dir         = hiera('phpmyadmin::root_dir')
  $access_log_file  = hiera('phpmyadmin::access_log_file')
  $error_log_file   = hiera('phpmyadmin::error_log_file')
  $absolute_uri     = hiera('phpmyadmin::absolute_uri')
  $revision         = hiera('phpmyadmin::revision')
  $servers          = hiera('phpmyadmin::servers')
  $user             = hiera('filesystem::owner')
  $fastcgi_read_timeout = hiera('nginx::fastcgi_read_timeout')
  $execpath         = "/bin:/usr/bin:/usr/local/bin"
  $execcheck        = "ls ${root_dir} | grep index.php"

  file { "${root_dir}":
    ensure => directory,
    owner  => $user
  }

  exec { 'download-phpmyadmin':
    command => "wget https://github.com/phpmyadmin/phpmyadmin/archive/${revision}.tar.gz -O /tmp/phpmyadmin.tar.gz",
    path => $execpath,
    unless => $execcheck
  }

  exec { 'extract-phpmyadmin':
    command => "tar -zxvf /tmp/phpmyadmin.tar.gz -C /tmp",
    path => $execpath,
    unless => $execcheck,
    require => Exec['download-phpmyadmin']
  }

  exec { 'move-phpmyadmin':
    command => "cp -R /tmp/phpmyadmin-${revision}/* ${root_dir}/",
    path => $execpath,
    unless => $execcheck,
    require => [
        File["${root_dir}"],
        Exec['extract-phpmyadmin']
    ]
  }

  file { "${root_dir}/config.inc.php":
    content => template('profiles/phpmyadmin/phpmyadmin.config.erb'),
    owner   => $user,
    require => [
      File["${root_dir}"],
      Exec['move-phpmyadmin']
    ]
  }

  profiles::nginx::config { "phpmyadmin.conf":
    content => template('profiles/phpmyadmin/nginx.config.erb'),
    require => File["${root_dir}/config.inc.php"]
  }
}