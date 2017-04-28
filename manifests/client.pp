# Installs LDAP client utilities.
#
# This class is optional in the scenario of an Operating System that packages
# the LDAP libraries and clients together in one package, use the `openldap`
# class to install that single package.
#
# @example Declaring the class
#   include ::openldap::client
#
# @param package_name The name of the package.
#
# @see puppet_classes::openldap ::openldap
class openldap::client (
  String $package_name = $::openldap::params::client_package_name,
) inherits ::openldap::params {

  if ! defined(Class['::openldap']) {
    fail('You must include the openldap base class before using the openldap::client class')
  }

  contain ::openldap::client::install
}
