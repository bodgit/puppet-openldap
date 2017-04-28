# Flatten an array of syncrepl directives to an array of strings.
#
# @param values The array of directives to flatten, `undef` is passed through.
#
# @return [Optional[Array[String, 1]]] The array of flattened directives.
#
# @example
#   openldap::flatten_syncrepl([{'rid' => 1, 'provider' => 'ldap://ldap.example.com', 'searchbase' => 'dc=example,dc=com'}])
#
# @since 2.0.0
function openldap::flatten_syncrepl(Optional[Array[OpenLDAP::Syncrepl, 1]] $values) {

  $values ? {
    undef   => undef,
    default => $values.map |OpenLDAP::Syncrepl $s| {
      join([sprintf('rid=%03d', $s['rid'])] + $s.filter |$x| {
        $x[0] != 'rid'
      }.map |$x| {
        case $x[0] {
          'binddn', 'logbase', 'logfilter', 'searchbase': {
            "${x[0]}=\"${x[1]}\""
          }
          'retry': {
            "${x[0]}=\"${join(flatten($x[1]), ' ')}\""
          }
          'schemachecking': {
            "${x[0]}=${bool2str($x[1], 'on', 'off')}"
          }
          default: {
            "${x[0]}=${x[1]}"
          }
        }
      }, ' ')
    },
  }
}
