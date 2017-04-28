# Flatten security strength factors to string form.
#
# @param value The strength factors to flatten, `undef` is passed through.
#
# @return [Optional[String]] The flattened strength factors.
#
# @example
#   openldap::flatten_security({'ssf' => 256})
#
# @since 2.0.0
function openldap::flatten_security(Optional[OpenLDAP::Security] $value) {

  $value ? {
    undef   => undef,
    default => join(join_keys_to_values($value, '='), ' '),
  }
}
