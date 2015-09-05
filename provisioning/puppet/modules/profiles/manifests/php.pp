class profiles::php {
  require apt

  $user                    = hiera('filesystem::owner')
  $group                   = hiera('filesystem::group')
  $memory_limit            = hiera('php::memory_limit')
  $error_reporting         = hiera('php::error_reporting')
  $display_errors          = hiera('php::display_errors')
  $display_startup_errors  = hiera('php::display_startup_errors')
  $post_max_size           = hiera('php::post_max_size')
  $upload_max_filesize     = hiera('php::upload_max_filesize')
  $max_file_uploads        = hiera('php::max_file_uploads')
  $max_execution_time      = hiera('php::max_execution_time')
  $pm_type                 = hiera('fpm::pm::type')
  $pm_max_children         = hiera('fpm::pm::max_children', '5')
  $pm_start_servers        = hiera('fpm::pm::start_servers', '2')
  $pm_min_spare_servers    = hiera('fpm::pm::min_spare_servers', '1')
  $pm_max_spare_servers    = hiera('fpm::pm::max_spare_servers', '3')
  $pm_max_requests         = hiera('fpm::pm::max_requests', '500')
  $pm_process_idle_timeout = hiera('fpm::pm::process_idle_timeout', '10s')
  $emergency_restart_threshold = hiera('fpm::emergency_restart_threshold')
  $emergency_restart_interval  = hiera('fpm::emergency_restart_interval')
  $process_control_timeout     = hiera('fpm::process_control_timeout')
  $execpath                = '/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin/'
  $config_path             = '/etc/php5'

  package { [
      'php5-fpm',
      'php5-cli',
      'php5-mysql',
      'php5-curl',
      'php5-gd',
      'php5-dev',
      'php5-xdebug',
      'php-pear',
      'php5-mcrypt',
      'libcurl3-openssl-dev'
    ]:
    ensure => present
  }

  service { 'php5-fpm':
    ensure => running,
    require => Package['php5-fpm'],
  }

  # upgrade pear
  exec { "pear upgrade":
    command => "pear upgrade",
    path => "${execpath}",
    require => Package['php-pear'],
  }

  # set channels to auto discover
  exec { "pear auto_discover":
    command => "pear config-set auto_discover 1",
    path => "${execpath}",
    require => Package['php-pear']
  }

  # update channels
  exec { "pear update-channels" :
    command => "pear update-channels",
    path => "${execpath}",
    require => Package['php-pear']
  }

  exec { 'enmod-mcrypt' :
    command => 'php5enmod mcrypt && php --ini',
    path => "${execpath}",
    require => [Package['php5-fpm'], Package['php5-mcrypt']],
    notify => Service['php5-fpm'],
  }

  exec { 'install-pecl_http':
    command => 'pecl install pecl_http-1.7.6',
    unless => 'pecl list | grep "pecl_http 1.7.6"',
    path => "${execpath}",
    require => [
      Package['php5-dev'],
      Package['libcurl3-openssl-dev']
    ]
  }

  file { "${config_path}/mods-available/http.ini":
    content => "extension=http.so",
    require => [
      Exec['install-pecl_http']
    ]
  }

  exec { 'enmod-pecl_http':
    command => 'php5enmod http && php --ini',
    path => "${execpath}",
    require => [
      File["${config_path}/mods-available/http.ini"]
    ],
    notify => Service['php5-fpm']
  }

  file { "${config_path}/fpm/php.ini":
    content => template('profiles/php/php.ini.erb'),
    require => [
      Package['php5-fpm'],
      Package['php5-mcrypt']
    ],
    notify => Service['php5-fpm'],
  }

  file { "${config_path}/fpm/pool.d/www.conf":
    content => template('profiles/php/www.conf.erb'),
    require => [
      Package['php5-fpm'],
      Package['php5-mcrypt']
    ],
    notify => Service['php5-fpm'],
  }

  file { "${config_path}/fpm/php-fpm.conf":
    content => template('profiles/php/php-fpm.conf.erb'),
    require => [
      Package['php5-fpm'],
      Package['php5-mcrypt']
    ],
    notify => Service['php5-fpm'],
  }
}