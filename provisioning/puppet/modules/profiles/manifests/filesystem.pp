class profiles::filesystem {

  $owner = hiera('filesystem::owner')
  $group = hiera('filesystem::group')
  $src_dir = hiera('filesystem::src_dir')
  $www_dir = hiera('filesystem::www_dir')

  group { "${group}":
    ensure => 'present'
  }

  user { "${owner}":
    ensure => 'present',
    groups => ["${group}"],
    require => Group["${group}"]
  }

  file { "${src_dir}":
    ensure => 'directory',
    owner => $owner,
    group => $group
  }

  exec { "chmod -R 775 ${src_dir}":
    path => "/bin:/usr/bin:/usr/local/bin",
    require => File["${src_dir}"]
  }

  file { "${www_dir}":
    ensure  => 'link',
    target  => "${src_dir}",
    require => File["${src_dir}"]
  }
}