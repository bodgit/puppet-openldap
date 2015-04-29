#
class openldap::server::install {

  $package_name = $::openldap::server::package_name
  $user         = $::openldap::server::user
  $group        = $::openldap::server::group

  case $::osfamily { # lint:ignore:case_without_default
    'RedHat': {
      $responsefile     = undef
      $comment          = 'OpenLDAP server'
      $gid              = 55
      $password         = '!!'
      $password_max_age = -1
      $password_min_age = -1
      $shell            = '/sbin/nologin'
      $uid              = $gid
    }
    'Debian': {
      $responsefile     = '/var/cache/debconf/slapd.preseed'
      $comment          = 'OpenLDAP Server Account,,,'
      $gid              = undef
      $password         = '!'
      $password_max_age = 99999
      $password_min_age = 0
      $shell            = '/bin/false'
      $uid              = undef

      file { $responsefile:
        ensure => file,
        owner  => 0,
        group  => 0,
        mode   => '0644',
        source => "puppet:///modules/openldap/${::osfamily}/slapd.preseed",
        before => Package[$package_name],
      }
    }
  }

  group { $group:
    ensure => present,
    gid    => $gid,
    system => true,
  }

  user { $user:
    ensure           => present,
    comment          => $comment,
    gid              => $group,
    home             => $::openldap::server::data_directory,
    password         => $password,
    password_max_age => $password_max_age,
    password_min_age => $password_min_age,
    shell            => $shell,
    system           => true,
    uid              => $uid,
    require          => Group[$group],
  }

  # Both RHEL and Debian try by default to create a default database which
  # thanks to OpenLDAP's own perculiarities is tedious to purge. We can use
  # debconf to stop Debian doing this but thanks to Debian's policy of always
  # trying to start daemons by default it will cause the package install to
  # fail if there is no configuration at all. Pre-populating this directory
  # before package installation with the absolute bare minimum configuration
  # allows things to work and is enough to stop the post-install logic in the
  # RHEL package from firing as well
  file { "${::openldap::server::conf_dir}/slapd.d":
    ensure             => directory,
    owner              => $user,
    group              => $group,
    source_permissions => use_when_creating,
    replace            => false,
    recurse            => true,
    source             => "puppet:///modules/openldap/${::osfamily}/slapd.d",
    before             => Package[$package_name],
    require            => [
      User[$user],
      Group[$group],
    ],
  }

  package { $::openldap::server::package_name:
    ensure       => present,
    responsefile => $responsefile,
  }
}
