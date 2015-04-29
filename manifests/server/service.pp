#
class openldap::server::service {

  service { $::openldap::server::server_service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
