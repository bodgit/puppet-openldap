# @!visibility private
class openldap::server::service {

  $user       = $::openldap::server::user
  $interfaces = $::openldap::server::interfaces

  $flags = $::osfamily ? {
    'OpenBSD' => inline_template('-u <%= @user %> -h ldapi:///<% if @interfaces %>\\ <%= @interfaces.join("\\\\ ") %><% end %>'),
    default   => undef,
  }

  service { $::openldap::server::server_service_name:
    ensure     => running,
    enable     => true,
    flags      => $flags,
    hasstatus  => true,
    hasrestart => true,
  }
}
