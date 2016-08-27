# openldap

Tested with Travis CI

[![Build Status](https://travis-ci.org/bodgit/puppet-openldap.svg?branch=master)](https://travis-ci.org/bodgit/puppet-openldap)
[![Coverage Status](https://coveralls.io/repos/bodgit/puppet-openldap/badge.svg?branch=master&service=github)](https://coveralls.io/github/bodgit/puppet-openldap?branch=master)
[![Puppet Forge](http://img.shields.io/puppetforge/v/bodgit/openldap.svg)](https://forge.puppetlabs.com/bodgit/openldap)
[![Dependency Status](https://gemnasium.com/bodgit/puppet-openldap.svg)](https://gemnasium.com/bodgit/puppet-openldap)

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
    * [Native Types](#native-types)
        * [Native Type: openldap](#native-type-openldap)
    * [Functions](#functions)
        * [Function: openldap_unique_indices](#function-openldap_unique_indices)
        * [Function: openldap_values](#function-openldap_values)
        * [Function: validate_openldap_unique_uri](#function-validate_openldap_unique_uri)
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
* Managing the global and any per-user LDAP client configuration.
* Installing client utilities.
* Installing and configuring the `slapd` daemon.
* The service controlling the `slapd` daemon.

### Beginning with openldap

```puppet
include ::openldap
```

## Usage

### Classes and Defined Types

#### Class: `openldap`

**Parameters within `openldap`:**

##### `package_name`

The name of the package to install that provides the LDAP libraries.

##### `conf_dir`

The base configuration directory, usually `/etc/openldap` or `/etc/ldap`.

##### `ldap_conf_file`

The global configuration file, normally `${conf_dir}/ldap.conf`.

##### `base`

See the `base` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `uri`

See the `uri` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `deref`

See the `deref` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `network_timeout`

See the `network_timeout` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `referrals`

See the `referrals` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `sizelimit`

See the `sizelimit` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `timelimit`

See the `timelimit` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `timeout`

See the `timeout` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `sasl_secprops`

See the `sasl_secprops` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `sasl_nocanon`

See the `sasl_nocanon` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `gssapi_sign`

See the `gssapi_sign` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `gssapi_encrypt`

See the `gssapi_encrypt` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `gssapi_allow_remote_principal`

See the `gssapi_allow_remote_principal` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `tls_cacert`

See the `tls_cacert` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `tls_cacertdir`

See the `tls_cacertdir` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `tls_cipher_suite`

See the `tls_cipher_suite` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `tls_protocol_min`

See the `tls_protocol_min` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `tls_randfile`

See the `tls_randfile` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `tls_reqcert`

See the `tls_reqcert` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `tls_crlcheck`

See the `tls_crlcheck` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

##### `tls_crlfile`

See the `tls_crlfile` parameter in [`openldap::configuration`](#defined-type-openldapconfiguration).

#### Class: `openldap::client`

**Parameters within `openldap::client`:**

##### `package_name`

The name of the package to install that provides the LDAP client utilities.

#### Class: `openldap::server`

**Parameters within `openldap::server`:**

##### `root_dn`

The Root Distinguished Name used to administer the database.

##### `root_password`

The password for the Root Distinguished Name.

##### `suffix`

The suffix for the main database.

##### `access`

An array of ACLs to apply to the database, in the same form as the `olcAccess`
attribute.

Do not include an ACL for the DN used by replication, one is added
automatically when the `syncprov` parameter is used.

##### `accesslog`

Setting this to `true` will enable the `accesslog` overlay in conjunction
with the `syncprov` overlay to enable delta replication.

It will create a separate database with the suffix `cn=log` and use the value
of the `replica_dn` parameter much like the `syncprov` setting to allow it to
be accessed by consumers.

##### `accesslog_cachesize`

Specify the size of the in-memory entry cache maintained by the `bdb` or
`hdb` backends for the database used by the `accesslog` overlay. See the
`olcDbCacheSize` attribute.

##### `accesslog_checkpoint`

Specify the frequency for checkpointing the transaction log of the database
used by the `accesslog` overlay. This is specified in the same form as the
`olcDbCheckpoint` attribute.

##### `accesslog_db_config`

An array of lines in the same form as the `olcDbConfig` attribute to tune the
database used by the `accesslog` overlay. This results in creating a
`DB_CONFIG` file for the database if the backend is either `bdb` or `hdb`.

##### `accesslog_dn_cachesize`

Specify the size of the in-memory DN cache maintained by the `bdb` or
`hdb` backends for the database used by the `accesslog` overlay. See the
`olcDbDNcacheSize` attribute.

##### `accesslog_index_cachesize`

Specify the size of the in-memory index cache maintained by the `bdb` or
`hdb` backends for the database used by the `accesslog` overlay. See the
`olcDbIDLcacheSize` attribute.

##### `args_file`

Where `slapd` writes out its command-line arguments.

##### `auditlog`

Setting this to `true` will enable the `auditlog` overlay.

##### `auditlog_file`

The LDIF file where the `auditlog` overlay writes any changes.

##### `authz_policy`

Maps to the `olcAuthzPolicy` attribute, accepts one of `none`, `from`, `to`,
`any`, or `all`.

##### `backend_modules`

An array of database backends that are built as modules and therefore require
loading before use.

##### `chain`

Setting this to `true` enables the `chain` overlay which transparently
forwards writes to a slave/consumer on behalf of the client to the
master/producer indicated by the configured update referral URI.

##### `chain_id_assert_bind`

Maps to the `olcDbIDAssertBind` attribute on the LDAP database used by the
chain overlay.

##### `chain_rebind_as_user`

Maps to the `olcDbRebindAsUser` attribute on the LDAP database used by the
chain overlay.

##### `chain_return_error`

Maps to the `olcChainReturnError` attribute on the chain overlay.

##### `chain_tls`

Maps to the `olcDbStartTLS` attribute on the LDAP database used by the chain
overlay. See the `tls` entry in the `slapd-ldap` man page for more information
on usage and accepted values.

##### `data_cachesize`

Specify the size of the in-memory entry cache maintained by the `bdb` or
`hdb` backends for the main database. See the `olcDbCacheSize` attribute.

##### `data_checkpoint`

Specify the frequency for checkpointing the transaction log of the main
database. This is specified in the same form as the `olcDbCheckpoint`
attribute.

##### `data_db_config`

An array of lines in the same form as the `olcDbConfig` attribute to tune the
main database. This results in creating a `DB_CONFIG` file for the database
if the backend is either `bdb` or `hdb`.

##### `data_directory`

The base directory used for database storage. Rather than store one database
at the top level, this module creates a sub-directory per-database. Any
unmanaged files in the top-level directory will be purged.

##### `data_dn_cachesize`

Specify the size of the in-memory index cache maintained by the `bdb` or
`hdb` backends for the main database. See the `olcDbDNcacheSize` attribute.

##### `data_index_cachesize`

Specify the size of the in-memory index cache maintained by the `bdb` or
`hdb` backends for the main database. See the `olcDbIDLcacheSize` attribute.

##### `db_backend`

The chosen database backend, usually one of `hdb`, `bdb`, or `mdb`.

##### `group`

The group that runs the `slapd` process.

##### `indices`

An array of index definitions in the same form as the `olcDbIndex` attribute.

Do not include an index for the attributes applicable to the `syncprov`
overlay. They are added automatically.

##### `ldap_interfaces`

Any array of `address(:port)` values that will be wrapped with `ldap://` &
`/` to form a list of interfaces to listen on for regular LDAP (optionally
with STARTTLS) connections, traditionally on TCP port 389. For IPv6 values,
the address portion should be wrapped with `[]`'s, i.e.  `[address](:port)`.

##### `ldaps_interfaces`

Any array of `address(:port)` values that will be wrapped with `ldaps://` &
`/` to form a list of interfaces to listen on for LDAP over SSL connections,
traditionally on TCP port 636. For IPv6 values, the address portion should
be wrapped with `[]`'s, i.e. `[address](:port)`.

##### `limits`

An array of limits in the same form as the `olcLimits` attribute.

Do not include a limit for the DN used by replication, one is added
automatically when the `syncprov` parameter is used.

##### `local_ssf`

Security strength factor assigned to `ldapi` connections. This defaults to 256
which is a safeguard to prevent locking the Puppet agent out as it uses this
connection to manipulate the configuration.

##### `log_level`

Set the logging level. Maps to the `olcLogLevel` attribute.

##### `module_extension`

The extension module files have, normally `.la`.

##### `package_name`

The name of the package to install that provides the LDAP `slapd` daemon.

##### `password_crypt_salt_format`

The format of the salt for hashing user passwords. Corresponds to the
`olcPasswordCryptSaltFormat` attribute. See the entry in the
`slapd-config(5)` man page for formatting details.

##### `password_hash`

The password hashing scheme to use for user passwords. Can be set to a space
separated string containing any of the following:

* `{SSHA}`, `{SHA}`
* `{SMD5}`, `{MD5}`
* `{CRYPT}`
* `{CLEARTEXT}`

The following schemes are also accepted however this requires additional
modules to be loaded which are often not available by default:

* `{SSHA256}`, `{SSHA384}`, {SSHA512}`, `{SHA256}`, `{SHA384}`, `{SHA512}`
* `{TOTP1}`, `{TOTP256}`, `{TOTP512}`
* `{PBKDF2}`, `{PBKDF2-SHA1}`, `{PBKDF2-SHA256}`, `{PBKDF2-SHA512}`
* `{BSDMD5}`
* `{NS-MTA-MD5}`
* `{APR1}`
* `{RADIUS}`
* `{KERBEROS}`

If this is not set, LDAP uses `{SSHA}` by default. Corresponds to the
`olcPasswordHash` attribute.

##### `pid_file`

Where `slapd` writes out its PID.

##### `ppolicy`

Setting this to `true` will enable the `ppolicy` overlay on the main database
allowing the enforcement of password strength/complexity as well as account
lockout. You will need to ensure the `ppolicy` schema is loaded before you
try and create or load any policies.

##### `ppolicy_default`

A Distinguished Name of the default password policy object to use if a user
does not have a `pwdPolicySubEntry` attribute. This must exist under the
main suffix.

##### `ppolicy_forward_updates`

If this server is a consumer/slave this setting controls whether password
policy operational attributes are written locally or forwarded to the
producer/master, (which means they can come back via replication). This
requires enabling the `chain` overlay.

##### `ppolicy_hash_cleartext`

Setting this to `true` forces cleartext passwords to be hashed when updated
via Add or Modify operations. This is not necessary if the Password Modify
extended operation is normally used.

##### `ppolicy_use_lockout`

Setting this to `true` makes a bind to a locked account return an
`AccountLocked` error instead of `InvalidCredentials`.

##### `replica_dn`

The Distinguished Name used by consumer/slave servers to connect to this
server in order to replicate content.

##### `schema_dir`

The base directory used to store the schemas shipped with OpenLDAP. This is
used as a default by the
[`openldap::server::schema`](#defined-type-openldapserverschema) defined type.

##### `security`

Specify minimum security strength factors in the same form as the
`olcSecurity` attribute.

##### `size_limit`

Specify the maximum number of entries to return from a search operation. Maps
to the `olcSizeLimit` attribute set on the `frontend` database.

##### `smbk5pwd`

Setting this to `true` will enable the `smbk5pwd` overlay. In order to add this
overlay to the database, the schema files for any enabled backends also need to
be loaded. Both Red Hat and Debian/Ubuntu enable the Samba backend by default
which requires the Samba schema. Debian/Ubuntu additionally enable the Kerberos
backend which requires the Heimdal KDC/HDB schema and also `slapd` will need to
be able to access the KDC master key (`m-key`) file.

##### `smbk5pwd_backends`

By default, all backends compiled into the overlay are enabled. Pass in an
array of backends to enable only some of them. This affects which schemas
need to be loaded and any additional setup steps. This maps to the
`olcSmbK5PwdEnable` attribute.

##### `smbk5pwd_must_change`

Maps to the `olcSmbK5PwdMustChange` attribute controlling how long until Samba
passwords expire after a password change.

##### `ssl_ca`

Maps to the `olcTLSCACertificateFile` attribute.

##### `ssl_cert`

Maps to the `olcTLSCertificateFile` attribute.

##### `ssl_certs_dir`

Maps to the `olcTLSCACertificatePath` attribute.

##### `ssl_cipher`

Maps to the `olcTLSCipherSuite` attribute.

##### `ssl_dhparam`

Maps to the `olcTLSDHParamFile` attribute.

##### `ssl_key`

Maps to the `olcTLSCertificateKeyFile` attribute.

##### `ssl_protocol`

Maps to the `olcTLSProtocolMin` attribute.

##### `syncprov`

Setting this to `true` will enable the `syncprov` overlay on the main database
allowing consumer/slave servers to replicate the content.

An additional index `entryCSN,entryUUID eq` will be appended to those passed
by the `indices` parameter.

The value of the `replica_dn` parameter is also used to prepend the ACL `to *
by dn.exact="${replica_dn}" read by * break` to those passed by the `access`
parameter to allow the consumers to read all of the data. The limit
`dn.exact="${replica_dn}" time.soft=unlimited time.hard=unlimited
size.soft=unlimited size.hard=unlimited` is also prepended to any limits passed
with the `limits` parameter.

##### `syncprov_checkpoint`

Maps to the `olcSpCheckpoint` attribute.

##### `syncprov_sessionlog`

Maps to the `olcSpSessionlog` attribute.

##### `syncrepl`

An array of `olcSyncrepl` attribute values used to establish a replication
relationship between this server and a producer.

##### `time_limit`

Specify the maximum number of seconds `slapd` will spend answering a search
request. Maps to the `olcTimeLimit` attribute set on the `frontend` database.

##### `unique`

Setting this to `true` will enable the `unique` overlay on the main database
allowing the enforcement of attribute value uniqueness.

##### `unique_uri`

Maps to the `olcUniqueURI` attribute. Values are validated with the
[`validate_openldap_unique_uri`](#function-validate_openldap_unique_uri)
function.

##### `update_ref`

A referral URI to return for referring writes from a read-only replica server
to the original producer/master server.

##### `user`

The user that runs the `slapd` process.

#### Defined Type: `openldap::configuration`

**Parameters within `openldap::configuration`:**

##### `name`

Path to the `file` resource.

##### `ensure`

Same as a `file` resource, i.e. `present`, `absent` or `file`.

##### `owner`

Same as a `file` resource.

##### `group`

Same as a `file` resource.

##### `mode`

Same as a `file` resource.

##### `base`

Maps to the `BASE` `ldap.conf` option.

##### `uri`

Maps to the `URI` `ldap.conf` option.

##### `binddn`

Maps to the `BINDDN` `ldap.conf` option.

##### `deref`

Maps to the `DEREF` `ldap.conf` option.

##### `network_timeout`

Maps to the `NETWORK_TIMEOUT` `ldap.conf` option.

##### `referrals`

Maps to the `REFERRALS` `ldap.conf` option.

##### `sizelimit`

Maps to the `SIZELIMIT` `ldap.conf` option.

##### `timelimit`

Maps to the `TIMELIMIT` `ldap.conf` option.

##### `timeout`

Maps to the `TIMEOUT` `ldap.conf` option.

##### `sasl_mech`

Maps to the `SASL_MECH` `ldap.conf` option.

##### `sasl_realm`

Maps to the `SASL_REALM` `ldap.conf` option.

##### `sasl_authcid`

Maps to the `SASL_AUTHCID` `ldap.conf` option.

##### `sasl_authzid`

Maps to the `SASL_AUTHZID` `ldap.conf` option.

##### `sasl_secprops`

Maps to the `SASL_SECPROPS` `ldap.conf` option.

##### `sasl_nocanon`

Maps to the `SASL_NOCANON` `ldap.conf` option.

##### `gssapi_sign`

Maps to the `GSSAPI_SIGN` `ldap.conf` option.

##### `gssapi_encrypt`

Maps to the `GSSAPI_ENCRYPT` `ldap.conf` option.

##### `gssapi_allow_remote_principal`

Maps to the `GSSAPI_ALLOW_REMOTE_PRINCIPAL` `ldap.conf` option.

##### `tls_cacert`

Maps to the `TLS_CACERT` `ldap.conf` option.

##### `tls_cacertdir`

Maps to the `TLS_CACERTDIR` `ldap.conf` option.

##### `tls_cert`

Maps to the `TLS_CERT` `ldap.conf` option.

##### `tls_key`

Maps to the `TLS_KEY` `ldap.conf` option.

##### `tls_cipher_suite`

Maps to the `TLS_CIPHER_SUITE` `ldap.conf` option.

##### `tls_protocol_min`

Maps to the `TLS_PROTOCOL_MIN` `ldap.conf` option.

##### `tls_randfile`

Maps to the `TLS_RANDFILE` `ldap.conf` option.

##### `tls_reqcert`

Maps to the `TLS_REQCERT` `ldap.conf` option.

##### `tls_crlcheck`

Maps to the `TLS_CRLCHECK` `ldap.conf` option.

##### `tls_crlfile`

Maps to the `TLS_CRLFILE` `ldap.conf` option.

#### Defined Type: `openldap::server::schema`

**Parameters within `openldap::server::schema`:**

##### `name`

The Common Name of the schema, i.e. `core`, `inetorgperson`, etc.

##### `position`

Position of schema in the list. This maps to the DN of the schema object, i.e.
`cn={${position}}${name},cn=schema`.

This module always loads the `core` schema at position 0 so this should be
from 1 onwards with no gaps.

##### `attributes`

Hash of additional attributes, defaults to `{}`.

##### `ldif`

LDIF file containing the schema, if not set will default to
`${schema_dir}/${name}.ldif` which handles any schema shipped with OpenLDAP.

See the [`openldap`](#native-type-openldap) type.

##### `purge`

Defaults to `false`, see the [`openldap`](#native-type-openldap) type.

### Native Types

#### Native Type: `openldap`

```puppet
openldap { 'cn=schema,cn=config':
  ensure     => present,
  attributes => {
    'cn'          => 'schema',
    'objectClass' => 'olcSchemaConfig',
  },
}
```

This type autorequires parent objects, (`Openldap['cn=config'] ->
Openldap['cn=schema,cn=config']`), as well as siblings if they use the OpenLDAP
positional syntax, (`Openldap['olcDatabase={0}config,cn=config'] ->
Openldap['olcDatabase={1}monitor,cn=config']`). Other relationships should
be explicitly declared if certain objects are required to exist before others.

**Parameters within `openldap`:**

##### `ensure`

Standard ensurable parameter. Be aware that quite a lot of OpenLDAP
configuration settings are additive and that the server will be "unwilling to
perform" deletion. For example dynamic modules can be loaded, but cannot be
unloaded again.

##### `attributes`

Hash of object attributes `'name' => 'value'`. In the case of multiple values,
use an array of values `'name' => ['value1', 'value2']`.

If a file resource exists in the catalogue for any value of a known set of
attributes, (`olcDbDirectory`, `olcTLSCertificateFile`, etc.), then it will be
autorequired.

##### `purge`

Controls purging of unknown attributes and/or values. Defaults to `true` to
purge anything not explicitly declared but can also be set to `false` so that
only missing attributes are added, or `partial` which purges any unknown
attribute values for explcitly declared attributes, but will leave alone any
attributes not declared.

##### `ldif`

Path to LDIF file containing the object definition which is used *only* if the
object does not exist yet, (This is a shortcut for loading huge schema files
without duplicating the whole schema object in the catalogue). A `puppet:///`
URL can also be used for the location of the LDIF file.

If a file resource exists in the catalogue for this value it will be
autorequired.

##### `service`

The name of the service controlling the `slapd` daemon. In order to affect
change the daemon needs to be running first. The service resource will be
autorequired.

### Functions

#### Function: `openldap_unique_indices`

Canonicalise and unique an array of index directives.

~~~
openldap_unique_indices(['entryCSN,entryUUID eq', 'ou,cn eq,pres,sub', 'entryCSN eq', 'entryUUID eq'])
~~~

#### Function: `openldap_values`

Prefix an array of values with positional `{x}` notation.

~~~
openldap_values(['foo', 'bar'])
~~~

#### Function: `validate_openldap_unique_uri`

Validate an array of LDAP URI values suitable for configuring the `unique`
overlay.

~~~
validate_openldap_unique_uri('dc=example,dc=com', ['ldap:///?uidNumber?sub'])
validate_openldap_unique_uri('dc=example,dc=com', ['ldap:///ou=people,dc=example,dc=com?uidNumber?sub'])
~~~

### Examples

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
  root_dn         => 'cn=Manager,dc=example,dc=com',
  root_password   => '{SSHA}7dSAJPGe4YKKEvUPuGJIeSL/03GV2IMY',
  suffix          => 'dc=example,dc=com',
  access          => [
    'to attrs=userPassword by self =xw by anonymous auth',
    'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by self write by users read',
  ],
  indices         => [
    'objectClass eq,pres',
    'ou,cn,mail,surname,givenname eq,pres,sub',
  ],
  ldap_interfaces => [$ipaddress],
}
::openldap::server::schema { 'cosine':
  position => 1,
}
::openldap::server::schema { 'inetorgperson':
  position => 2,
}
::openldap::server::schema { 'nis':
  position => 3,
}
```

Extend the above example to become a producer/master server for a number of
consumer/slave servers:

```puppet
include ::openldap
include ::openldap::client

class { '::openldap::server':
  root_dn         => 'cn=Manager,dc=example,dc=com',
  root_password   => '{SSHA}7dSAJPGe4YKKEvUPuGJIeSL/03GV2IMY',
  suffix          => 'dc=example,dc=com',
  access          => [
    'to attrs=userPassword by self =xw by anonymous auth',
    'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by self write by users read',
  ],
  indices         => [
    'objectClass eq,pres',
    'ou,cn,mail,surname,givenname eq,pres,sub',
  ],
  ldap_interfaces => [$ipaddress],
  replica_dn      => 'cn=replicator,dc=example,dc=com',
  syncprov        => true,
}
::openldap::server::schema { 'cosine':
  position => 1,
}
::openldap::server::schema { 'inetorgperson':
  position => 2,
}
::openldap::server::schema { 'nis':
  position => 3,
}
```

Extend this further to also enable delta replication:

```puppet
include ::openldap
include ::openldap::client

class { '::openldap::server':
  root_dn         => 'cn=Manager,dc=example,dc=com',
  root_password   => '{SSHA}7dSAJPGe4YKKEvUPuGJIeSL/03GV2IMY',
  suffix          => 'dc=example,dc=com',
  access          => [
    'to attrs=userPassword by self =xw by anonymous auth',
    'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by self write by users read',
  ],
  accesslog       => true,
  indices         => [
    'objectClass eq,pres',
    'ou,cn,mail,surname,givenname eq,pres,sub',
  ],
  ldap_interfaces => [$ipaddress],
  replica_dn      => 'cn=replicator,dc=example,dc=com',
  syncprov        => true,
}
::openldap::server::schema { 'cosine':
  position => 1,
}
::openldap::server::schema { 'inetorgperson':
  position => 2,
}
::openldap::server::schema { 'nis':
  position => 3,
}
```

Create a server acting as a consumer of another server using delta replication
and pass back a referral to clients on attempting to write:

```puppet
include ::openldap
include ::openldap::client

class { '::openldap::server':
  root_dn         => 'cn=Manager,dc=example,dc=com',
  root_password   => '{SSHA}7dSAJPGe4YKKEvUPuGJIeSL/03GV2IMY',
  suffix          => 'dc=example,dc=com',
  access          => [
    'to attrs=userPassword by self =xw by anonymous auth',
    'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by self write by users read',
  ],
  indices         => [
    'objectClass eq,pres',
    'ou,cn,mail,surname,givenname eq,pres,sub',
  ],
  ldap_interfaces => [$ipaddress],
  syncrepl        => [
    'rid=001 provider=ldap://ldap.example.com/ searchbase="dc=example,dc=com" bindmethod=simple binddn="cn=replicator,dc=example,dc=com" credentials=secret logbase="cn=log" logfilter="(&(objectClass=auditWriteObject)(reqResult=0))" schemachecking=on type=refreshAndPersist retry="60 +" syncdata=accesslog',
  ],
  update_ref      => 'ldap://ldap.example.com/',
}
::openldap::server::schema { 'cosine':
  position => 1,
}
::openldap::server::schema { 'inetorgperson':
  position => 2,
}
::openldap::server::schema { 'nis':
  position => 3,
}
```

Extend the standalone example with support for synchronising passwords between
POSIX and Samba:

```puppet
include ::openldap
include ::openldap::client

class { '::openldap::server':
  root_dn           => 'cn=Manager,dc=example,dc=com',
  root_password     => '{SSHA}7dSAJPGe4YKKEvUPuGJIeSL/03GV2IMY',
  suffix            => 'dc=example,dc=com',
  access            => [
    'to attrs=userPassword by self =xw by anonymous auth',
    'to attrs=sambaLMPassword,sambaNTPassword by self =w',
    'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by self write by users read',
  ],
  indices           => [
    'objectClass eq,pres',
    'ou,cn,mail,surname,givenname eq,pres,sub',
  ],
  ldap_interfaces   => [$ipaddress],
  smbk5pwd          => true,
  smbk5pwd_backends => ['samba'],
}
::openldap::server::schema { 'cosine':
  position => 1,
}
::openldap::server::schema { 'inetorgperson':
  position => 2,
}
::openldap::server::schema { 'nis':
  position => 3,
}
package { 'samba':
  ensure => present,
}
::openldap::server::schema { 'samba':
  ldif     => '/usr/share/doc/samba-4.1.12/LDAP/samba.ldif',
  position => 4,
  require  => Package['samba'],
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

### Native Types

* [`openldap`](#native-type-openldap): Manages a configuration object in the
  `slapd` OLC (`cn=config`) DIT.

### Functions

* [`openldap_unique_indices`](#function-openldap_unique_indices): Canonicalises
  and uniques a set of indices.
* [`openldap_values`](#function-openldap_values): Adds a positional `{x}`
  prefix to an array of values.
* [`validate_openldap_unique_uri`](#function-validate_openldap_unique_uri):
  Validates an array of URI values suitable for configuring the `unique`
  overlay.

## Limitations

Rather than expose overlays, modules, databases, etc. as defined or native
types and leave the user to build their own configuration this module takes
the decision to hide most of this complexity and build what most people
probably want out of OpenLDAP; a single database, possibly replicated. This
is largely due to a number of behaviours and idiosyncrasies of OpenLDAP; the
order of overlays matters for example.

As alluded to by the [`openldap`](#native-type-openldap) native type, a lot of
attributes or objects are additive and can't be deleted without manually
editing the configuration. This module will always try and issue the necessary
LDIF commands however the server will be "unwilling to perform" them. This
means that if you try to convert from say a replicating producer back to a
standalone server you will probably get errors from trying to remove the
various replication objects. However things should always build from scratch
cleanly.

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
