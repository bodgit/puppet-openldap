#
class openldap::client (
  $package_name   = $::openldap::params::client_package_name,
) inherits ::openldap::params {

  if ! defined(Class['::openldap']) {
    fail('You must include the openldap base class before using the openldap::client class ')
  }

  include ::openldap::client::install

  anchor { 'openldap::client::begin': }
  anchor { 'openldap::client::end': }

  Anchor['openldap::client::begin'] -> Class['::openldap::client::install']
    -> Anchor['openldap::client::end']
}
