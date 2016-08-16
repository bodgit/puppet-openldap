#
define openldap::server::schema (
  $position,
  $attributes = {},
  $ldif       = undef,
  $purge      = false,
) {

  if ! defined(Class['::openldap::server']) {
    fail('You must include the openldap::server class before using any openldap defined resources') # lint:ignore:80chars
  }

  $minimum_position = $caller_module_name ? {
    $module_name => 0,
    default      => 1,
  }

  validate_integer($position, '', $minimum_position)
  validate_string($ldif)
  validate_bool($purge)

  $_ldif = $ldif ? {
    undef   => "${::openldap::server::schema_dir}/${name}.ldif",
    default => $ldif,
  }

  openldap { "cn={${position}}${name},cn=schema,cn=config":
    ensure     => present,
    attributes => delete_undef_values($attributes),
    ldif       => $_ldif,
    purge      => $purge,
  }

  # Make sure the schema is loaded before the first database
  Openldap["cn={${position}}${name},cn=schema,cn=config"]
    -> Openldap['olcDatabase={-1}frontend,cn=config']
}
