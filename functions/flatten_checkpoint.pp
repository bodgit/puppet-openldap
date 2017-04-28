# Flatten a checkpoint specification to a string.
#
# @param value The value to flatten, `undef` is passed through.
#
# @return [Optional[String]] The flattened checkpoint as a string.
#
# @example
#   openldap::flatten_checkpoint([10, 100])
#
# @since 2.0.0
function openldap::flatten_checkpoint(Optional[OpenLDAP::Checkpoint] $value) {

  $value ? {
    undef   => undef,
    default => join($value, ' '),
  }
}
