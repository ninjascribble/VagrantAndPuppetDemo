class profiles::curl {
  require apt

  package { 'curl':
    ensure => present
  }
}