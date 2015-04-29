#
define openldap::server::schema (
  $position,
  $attributes = {},
  $ldif       = "${::openldap::server::schema_dir}/${name}.ldif",
  $purge      = false,
) {

  if ! defined(Class['::openldap::server']) {
    fail('You must include the openldap::server class before using any openldap defined resources') # lint:ignore:80chars
  }

  validate_integer($position)
  if $ldif {
    validate_absolute_path($ldif)
  }
  validate_bool($purge)

  openldap { "cn={${position}}${name},cn=schema,cn=config":
    ensure     => present,
    attributes => $attributes,
    ldif       => $ldif,
    purge      => $purge,
  }

  # Make sure the schema is loaded before the first database
  Openldap["cn={${position}}${name},cn=schema,cn=config"]
    -> Openldap['olcDatabase={-1}frontend,cn=config']
}
