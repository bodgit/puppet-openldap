# Flatten time limits to string form.
#
# @param value The time limits to flatten, `undef` is passed through.
#
# @return [Optional[String]] The flattened time limits.
#
# @example
#   openldap::flatten_time_limit('unlimited')
#   openldap::flatten_time_limit({'soft' => 0, 'hard' => 'unlimited'})
#
# @since 2.0.0
function openldap::flatten_time_limit(Optional[OpenLDAP::Limit::Time] $value) {

  type($value) ? {
    Type[Hash]   => join(join_keys_to_values(prefix($value, 'time.'), '='), ' '),
    Type[Scalar] => String($value),
    default      => undef,
  }
}
