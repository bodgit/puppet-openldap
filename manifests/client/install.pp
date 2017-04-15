# @!visibility private
class openldap::client::install {

  package { $::openldap::client::package_name:
    ensure => present,
  }
}
