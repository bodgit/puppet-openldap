#
class openldap::install {

  package { $::openldap::package_name:
    ensure => present,
  }
}
