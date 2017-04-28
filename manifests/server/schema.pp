# Loads a schema into the OpenLDAP server
#
# This wraps the `openldap_schema` type with a sane default for the LDIF file
# in the case of loading the standard OpenLDAP schemas.
#
# @example Loading a standard schema
#   ::openldap::server::schema { 'cosine':
#     ensure => present,
#   }
#
# @example Loading a third party schema from the filesystem
#   ::openldap::server::schema { 'openssh-lpk':
#     ensure => present,
#     ldif   => '/usr/share/doc/openssh-ldap-6.6.1p1/openssh-lpk-openldap.ldif',
#   }
#
# @example Loading a third party schema from another Puppet module
#   ::openldap::server::schema { 'postfix':
#     ensure => present,
#     ldif   => 'puppet:///postfix/postfix.ldif',
#   }
#
# @param ensure
# @param ldif Path to the LDIF file containing the schema, can be a local file
#   path, a `file://` URL, or a `puppet://` URL. Will default to the schema
#   directory for the server.
# @param schema The name of the schema.
#
# @see puppet_classes::openldap::server ::openldap::server
define openldap::server::schema (
  Enum['absent', 'present']                                                               $ensure = 'present',
  Optional[Variant[Stdlib::Absolutepath, Pattern[/^file:\/\//], Pattern[/^puppet:\/\//]]] $ldif   = undef,
  String[1]                                                                               $schema = $title,
) {

  if ! defined(Class['::openldap::server']) {
    fail('You must include the openldap::server class before using any openldap defined resources')
  }

  $_ldif = $ldif ? {
    undef   => "${::openldap::server::schema_dir}/${schema}.ldif",
    default => $ldif,
  }

  openldap_schema { $schema:
    ensure => $ensure,
    ldif   => $_ldif,
  }
}
