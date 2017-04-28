# Convert boolean values to their OpenLDAP form.
#
# @param value The boolean value to convert, `undef` is passed through
#   unchanged.
#
# @return [Optional[String]] One of `TRUE`, `FALSE` or `undef`.
#
# @example
#   openldap::boolean(true)
#   openldap::boolean(false)
#   openldap::boolean(undef)
#
# @since 2.0.0
function openldap::boolean(Optional[Boolean] $value) {

  $value ? {
    undef   => undef,
    default => bool2str($value, 'TRUE', 'FALSE'),
  }
}
