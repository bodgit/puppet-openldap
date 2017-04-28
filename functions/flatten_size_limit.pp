# Flatten size limits to string form.
#
# @param value The size limits to flatten, `undef` is passed through.
#
# @return [Optional[String]] The flattened size limits.
#
# @example
#   openldap::flatten_size_limit('unlimited')
#   openldap::flatten_size_limit({'soft' => 0, 'hard' => 'unlimited'})
#
# @since 2.0.0
function openldap::flatten_size_limit(Optional[OpenLDAP::Limit::Size] $value) {

  type($value) ? {
    Type[Hash]   => join(join_keys_to_values(prefix($value, 'size.'), '='), ' '),
    Type[Scalar] => String($value),
    default      => undef,
  }
}
