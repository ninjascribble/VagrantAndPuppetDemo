class apt {

  exec { 'apt-get update':
    path => '/usr/bin:/usr/local/bin'
  }
}
