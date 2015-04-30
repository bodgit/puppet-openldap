# openldap

Tested with Travis CI

[![Puppet Forge](http://img.shields.io/puppetforge/v/bodgit/openldap.svg)](https://forge.puppetlabs.com/bodgit/openldap)
[![Build Status](https://travis-ci.org/bodgit/puppet-openldap.svg?branch=master)](https://travis-ci.org/bodgit/puppet-openldap)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with openldap](#setup)
    * [What openldap affects](#what-openldap-affects)
    * [Beginning with openldap](#beginning-with-openldap)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Class: openldap](#class-openldap)
        * [Class: openldap::client](#class-openldapclient)
        * [Class: openldap::server](#class-openldapserver)
        * [Defined Type: openldap::configuration](#defined-type-openldapconfiguration)
        * [Defined Type: openldap::server::schema](#defined-type-openldapserverschema)
    * [Examples](#examples)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module manages OpenLDAP.

## Module Description

This module can install LDAP libraries, client utilities and more importantly
install and configure the `slapd` ḋaemon to provide directory services.

## Setup

### What openldap affects

* The package(s) providing LDAP support.
* Installing client utilities.
* Installing and configuring the `slapd` daemon.
* The service controlling the `slapd` daemon.
* Managing the global and any per-user LDAP client configuration.

### Beginning with openldap

```puppet
include ::openldap
```

## Usage

### Classes and Defined Types

#### Class: `openldap`

**Parameters within `openldap`:**

##### `package_name`

##### `conf_dir`

##### `ldap_conf_file`

##### `base`

##### `uri`

##### `deref`

##### `network_timeout`

##### `referrals`

##### `sizelimit`

##### `timelimit`

##### `timeout`

##### `sasl_secprops`

##### `sasl_nocanon`

##### `gssapi_sign`

##### `gssapi_encrypt`

##### `gssapi_allow_remote_principal`

##### `tls_cacert`

##### `tls_cacertdir`

##### `tls_cipher_suite`

##### `tls_protocol_min`

##### `tls_randfile`

##### `tls_reqcert`

##### `tls_crlcheck`

##### `tls_crlfile`

#### Class: `openldap::client`

**Parameters within `openldap::client`:**

##### `package_name`

#### Class: `openldap::server`

**Parameters within `openldap::server`:**

##### `root_dn`

##### `root_password`

##### `suffix`

##### `access`

##### `accesslog`

##### `args_file`

##### `backend_modules`

##### `data_directory`

##### `db_backend`

##### `$db_config`

##### `group`

##### `indices`

##### `ldap_interfaces`

##### `ldaps_interfaces`

##### `limits`

##### `module_extension`

##### `package_name`

##### `pid_file`

##### `replica_dn`

##### `schema_dir`

##### `ssl_ca`

##### `ssl_cert`

##### `ssl_certs_dir`

##### `ssl_cipher`

##### `ssl_dhparam`

##### `ssl_key`

##### `ssl_protocol`

##### `syncprov`

##### `syncprov_checkpoint`

##### `syncprov_sessionlog`

##### `syncrepl`

##### `update_ref`

##### `user`

#### Defined Type: `openldap::configuration`

**Parameters within `openldap::configuration`:**

##### `ensure`

##### `owner`

##### `group`

##### `mode`

##### `base`

##### `uri`

##### `binddn`

##### `deref`

##### `network_timeout`

##### `referrals`

##### `sizelimit`

##### `timelimit`

##### `timeout`

##### `sasl_mech`

##### `sasl_realm`

##### `sasl_authcid`

##### `sasl_authzid`

##### `sasl_secprops`

##### `sasl_nocanon`

##### `gssapi_sign`

##### `gssapi_encrypt`

##### `gssapi_allow_remote_principal`

##### `tls_cacert`

##### `tls_cacertdir`

##### `tls_cert`

##### `tls_key`

##### `tls_cipher_suite`

##### `tls_protocol_min`

##### `tls_randfile`

##### `tls_reqcert`

##### `tls_crlcheck`

##### `tls_crlfile`

#### Defined Type: `openldap::server::schema`

**Parameters within `openldap::server::schema`:**

##### `position`

##### `attributes`

##### `ldif`

##### `purge`

### Examples

```puppet
include ::openldap
```

```puppet
include ::openldap
include ::openldap::client
```

```puppet
include ::openldap
include ::openldap::client

class { '::openldap::server':
  root_dn       => 'cn=Manager,dc=example,dc=com',
  root_password => '{SSHA}7dSAJPGe4YKKEvUPuGJIeSL/03GV2IMY',
  suffix        => 'dc=example,dc=com',
}
```

## Reference

### Classes

#### Public Classes

* [`openldap`](#class-openldap): Main class for installing base LDAP library.
* [`openldap::client`](#class-openldapclient): Main class for installing LDAP client utilities.
* [`openldap::server`](#class-openldapserver): Main class for installing and managing `slapd` daemon.

#### Private Classes

* `openldap::config`: Handles base LDAP library configuration.
* `openldap::install`: Handles base LDAP library installation.
* `openldap::params`: Different configuration data for different systems.
* `openldap::client::install`: Handles LDAP client utility installation.
* `openldap::server::config`: Handles `slapd` configuration.
* `openldap::server::install`: Handles `slapd` installation.
* `openldap::server::service`: Handles starting the `slapd` daemon.

### Defined Types

#### Public Defined Types

* [`openldap::configuration`](#defined-type-openldapconfiguration): Handles
  creating global or per-user LDAP client configuration.
* [`openldap::server::schema`](#defined-type-openldapserverschema): Installs
  and enables LDAP schemas in `slapd`.

## Limitations

This module has been built on and tested against Puppet 3.0 and higher.

The module has been tested on:

* RedHat/CentOS Enterprise Linux 6/7
* Ubuntu 12.04/14.04
* Debian 6/7

It should also probably work on:

* Fedora 19/20 (need vagrant boxes for tests)

Testing on other platforms has been light and cannot be guaranteed.

## Development

Please log issues or pull requests at
[github](https://github.com/bodgit/puppet-openldap).
