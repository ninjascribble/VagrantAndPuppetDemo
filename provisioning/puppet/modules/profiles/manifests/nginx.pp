class profiles::nginx {
  require apt

  $processorcount = hiera('server::processorcount')
  $sendfile       = hiera('nginx::sendfile')
  $owner          = hiera('filesystem::owner')
  $client_max_body_size = hiera('php::post_max_size')
  $config_path    = '/etc/nginx'

  # Required for HTTP Basic auth
  package { 'apache2-utils':
    ensure => 'present'
  }

  # Install the nginx package
  package { 'nginx':
    ensure => 'present',
    require => Package['apache2-utils']
  }

  service { 'nginx':
    ensure => 'running',
    require => Package['nginx']
  }

  file { "${config_path}/nginx.conf":
    content => template('profiles/nginx/nginx.config.erb'),
    require => Package['nginx'],
    notify => Service['nginx']
  }

  # Disable the default nginx vhost
  file { "${config_path}/sites-enabled/default":
    ensure => absent,
    require => Package['nginx'],
  }

  # Disable the default old vhost
  file { "${config_path}/sites-enabled/127.0.0.1":
    ensure => absent,
    require => Package['nginx'],
  }
}

# Useful reading:
# https://blog.openshift.com/how-to-avoid-puppet-dependency-nightmares-with-defines/
define profiles::nginx::config (
  $ensure   = 'file',
  $content  = undef,
  $source   = undef
) {
  include profiles::nginx

  $owner            = hiera('filesystem::owner')
  $nginx_config_dir = hiera('nginx::config_dir')

  if $content and $source {
    fail('You may not supply both content and source parameters to httpd::conf::file')
  }
  elsif $content == undef and $source == undef {
    fail('You must supply either the content or source parameter to httpd::conf::file')
  }
 
  file { "$nginx_config_dir/${name}":
    ensure  => $ensure,
    owner   => $owner,
    group   => $owner,
    mode    => '0640',
    content => $content,
    source  => $source,
    require => Package['nginx'],
    notify  => Service['nginx'],
  }
}