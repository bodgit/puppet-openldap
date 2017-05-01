# openldap

Tested with Travis CI

[![Build Status](https://travis-ci.org/bodgit/puppet-openldap.svg?branch=master)](https://travis-ci.org/bodgit/puppet-openldap)
[![Coverage Status](https://coveralls.io/repos/bodgit/puppet-openldap/badge.svg?branch=master&service=github)](https://coveralls.io/github/bodgit/puppet-openldap?branch=master)
[![Puppet Forge](http://img.shields.io/puppetforge/v/bodgit/openldap.svg)](https://forge.puppetlabs.com/bodgit/openldap)
[![Dependency Status](https://gemnasium.com/bodgit/puppet-openldap.svg)](https://gemnasium.com/bodgit/puppet-openldap)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with openldap](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with openldap](#beginning-with-openldap)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module can install LDAP libraries, client utilities and more importantly
install and configure the `slapd` ḋaemon to provide directory services.

RHEL/CentOS, Ubuntu, Debian and OpenBSD are supported using Puppet 4.4.0 or
later.

## Setup

### Setup Requirements

You will need pluginsync enabled.

### Beginning with openldap

```puppet
include ::openldap
```

## Usage

Install the LDAP libraries and create a global `ldap.conf` mimicking the stock
RHEL/CentOS install as well as a per-user `.ldaprc` for any subsequently
created users. Also install the client utilities:

```puppet
class { '::openldap':
  tls_cacertdir => '/etc/openldap/certs'
}

::openldap::configuration { '/etc/skel/.ldaprc':
  ensure => file,
  owner  => 0,
  group  => 0,
  mode   => '0640',
  base   => 'dc=example,dc=com',
  uri    => ['ldap://ldap.example.com/'],
}

::Openldap::Configuration['/etc/skel/.ldaprc'] -> User <||>

include ::openldap::client
```

Create a standalone directory server listening on the standard LDAP TCP port
389 that disallows anonymous reads and allows users to update their own object:

```puppet
include ::openldap
include ::openldap::client

class { '::openldap::server':
  root_dn       => 'cn=Manager,dc=example,dc=com',
  root_password => '{SSHA}7dSAJPGe4YKKEvUPuGJIeSL/03GV2IMY',
  suffix        => 'dc=example,dc=com',
  access        => [
    'to attrs=userPassword by self =xw by anonymous auth',
    'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by self write by users read',
  ],
  indices       => [
    [['objectClass'], ['eq', 'pres']],
    [['ou', 'cn', 'mail', 'surname', 'givenname'], ['eq', 'pres', 'sub']],
  ],
  interfaces    => ["ldap://${::ipaddress}/"],
}
::openldap::server::schema { 'cosine':
  ensure => present,
}
::openldap::server::schema { 'inetorgperson':
  ensure => present,
}
::openldap::server::schema { 'nis':
  ensure  => present,
  require => ::Openldap::Server::Schema['cosine'],
}
```

## Reference

The reference documentation is generated with
[puppet-strings](https://github.com/puppetlabs/puppet-strings) and the latest
version of the documentation is hosted at
[https://bodgit.github.io/puppet-openldap/](https://bodgit.github.io/puppet-openldap/).

## Limitations

Rather than expose overlays, modules, databases, etc. as defined or native
types and leave the user to build their own configuration this module takes
the decision to hide most of this complexity and build what most people
probably want out of OpenLDAP; a single database, possibly replicated. This
is largely due to a number of behaviours and idiosyncrasies of OpenLDAP; the
order of overlays matters for example.

As alluded to by the openldap native type, a lot of attributes or objects are
additive and can't be deleted without manually editing the configuration. This
module will always try and issue the necessary LDIF commands however the server
will sometimes be "unwilling to perform" them. This means that if you try to
convert from say a replicating producer back to a standalone server you will
probably get errors from trying to remove the various replication objects.
However things should always build from scratch cleanly.

This module has been built on and tested against Puppet 4.4.0 and higher.

The module has been tested on:

* RedHat Enterprise Linux 6/7
* Ubuntu 14.04/16.04
* Debian 7/8
* OpenBSD 6.0

## Development

The module has both [rspec-puppet](http://rspec-puppet.com) and
[beaker-rspec](https://github.com/puppetlabs/beaker-rspec) tests. Run them
with:

```
$ bundle exec rake test
$ PUPPET_INSTALL_TYPE=agent PUPPET_INSTALL_VERSION=x.y.z bundle exec rake beaker:<nodeset>
```

Please log issues or pull requests at
[github](https://github.com/bodgit/puppet-openldap).
