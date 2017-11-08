# Change Log

## [v2.0.2](https://github.com/bodgit/puppet-openldap/tree/v2.0.2) (2017-11-08)
[Full Changelog](https://github.com/bodgit/puppet-openldap/compare/v2.0.1...v2.0.2)

## [v2.0.1](https://github.com/bodgit/puppet-openldap/tree/v2.0.1) (2017-05-15)
[Full Changelog](https://github.com/bodgit/puppet-openldap/compare/v2.0.0...v2.0.1)

**Implemented enhancements:**

- OpenBSD 6.1 support [\#50](https://github.com/bodgit/puppet-openldap/issues/50)

## [v2.0.0](https://github.com/bodgit/puppet-openldap/tree/v2.0.0) (2017-05-08)
[Full Changelog](https://github.com/bodgit/puppet-openldap/compare/v1.4.1...v2.0.0)

**Implemented enhancements:**

- Tidy up RSpec tests for openldap::server [\#48](https://github.com/bodgit/puppet-openldap/issues/48)
- Add dedicated resource type for managing schema objects [\#47](https://github.com/bodgit/puppet-openldap/issues/47)
- Puppet 4 update [\#46](https://github.com/bodgit/puppet-openldap/issues/46)
- Add writemap et nometasync support [\#45](https://github.com/bodgit/puppet-openldap/issues/45)
- OpenBSD support [\#20](https://github.com/bodgit/puppet-openldap/issues/20)

**Fixed bugs:**

- Fix Debian/Ubuntu acceptance tests [\#49](https://github.com/bodgit/puppet-openldap/issues/49)

## [v1.4.1](https://github.com/bodgit/puppet-openldap/tree/v1.4.1) (2017-03-09)
[Full Changelog](https://github.com/bodgit/puppet-openldap/compare/v1.4.0...v1.4.1)

**Fixed bugs:**

- 'referrals' parameter does not work properly [\#42](https://github.com/bodgit/puppet-openldap/issues/42)

## [v1.4.0](https://github.com/bodgit/puppet-openldap/tree/v1.4.0) (2017-01-31)
[Full Changelog](https://github.com/bodgit/puppet-openldap/compare/v1.3.0...v1.4.0)

## [v1.3.0](https://github.com/bodgit/puppet-openldap/tree/v1.3.0) (2016-08-30)
[Full Changelog](https://github.com/bodgit/puppet-openldap/compare/v1.2.0...v1.3.0)

**Implemented enhancements:**

- Add support for password hash attributes [\#39](https://github.com/bodgit/puppet-openldap/pull/39) ([tcsalameh](https://github.com/tcsalameh))

## [v1.2.0](https://github.com/bodgit/puppet-openldap/tree/v1.2.0) (2016-08-12)
[Full Changelog](https://github.com/bodgit/puppet-openldap/compare/v1.1.4...v1.2.0)

**Implemented enhancements:**

- Add support for ppolicy overlay [\#25](https://github.com/bodgit/puppet-openldap/issues/25)
- Add support for unique overlay [\#24](https://github.com/bodgit/puppet-openldap/issues/24)
- Add `openldap\_boolean` function [\#34](https://github.com/bodgit/puppet-openldap/issues/34)
- Add support for chain overlay [\#33](https://github.com/bodgit/puppet-openldap/issues/33)
- Pull in bodgitlib [\#27](https://github.com/bodgit/puppet-openldap/issues/27)
- Adds support for ppolicy overlay. [\#31](https://github.com/bodgit/puppet-openldap/pull/31) ([tcsalameh](https://github.com/tcsalameh))
- Adds support for unique overlay [\#29](https://github.com/bodgit/puppet-openldap/pull/29) ([tcsalameh](https://github.com/tcsalameh))

**Fixed bugs:**

- puppet-openldap uses non-existent function: validate\_number [\#38](https://github.com/bodgit/puppet-openldap/issues/38)
- Don't allow an array of update referral URLs [\#35](https://github.com/bodgit/puppet-openldap/issues/35)
- Setting `olcSecurity` without also setting `olcLocalSSF` can prevent further changes [\#22](https://github.com/bodgit/puppet-openldap/issues/22)

## [v1.1.4](https://github.com/bodgit/puppet-openldap/tree/v1.1.4) (2016-07-21)
[Full Changelog](https://github.com/bodgit/puppet-openldap/compare/v1.1.3...v1.1.4)

**Fixed bugs:**

- Canonicalize and ensure uniqueness of indices [\#28](https://github.com/bodgit/puppet-openldap/pull/28) ([tcsalameh](https://github.com/tcsalameh))

## [v1.1.3](https://github.com/bodgit/puppet-openldap/tree/v1.1.3) (2016-05-06)
[Full Changelog](https://github.com/bodgit/puppet-openldap/compare/v1.1.2...v1.1.3)

**Implemented enhancements:**

- Puppet 4 [\#21](https://github.com/bodgit/puppet-openldap/issues/21)

**Fixed bugs:**

- EL6 support [\#26](https://github.com/bodgit/puppet-openldap/issues/26)
- Passing in IPv6 addresses to `ldap\_interfaces` parameter aren't written out correctly [\#23](https://github.com/bodgit/puppet-openldap/issues/23)

## [v1.1.2](https://github.com/bodgit/puppet-openldap/tree/v1.1.2) (2016-03-15)
[Full Changelog](https://github.com/bodgit/puppet-openldap/compare/v1.1.1...v1.1.2)

**Implemented enhancements:**

- Support setting global size and time limits [\#18](https://github.com/bodgit/puppet-openldap/issues/18)
- Support setting log level [\#17](https://github.com/bodgit/puppet-openldap/issues/17)
- Allow LDIF files to be sourced from non-local locations [\#16](https://github.com/bodgit/puppet-openldap/issues/16)
- Support LDAP \<-\> Samba \<-\> Kerberos password synchronisation [\#11](https://github.com/bodgit/puppet-openldap/issues/11)
- Support setting database tuning options [\#9](https://github.com/bodgit/puppet-openldap/issues/9)

## [v1.1.1](https://github.com/bodgit/puppet-openldap/tree/v1.1.1) (2015-07-06)
[Full Changelog](https://github.com/bodgit/puppet-openldap/compare/v1.1.0...v1.1.1)

**Fixed bugs:**

- olcSyncrepl always gets reapplied [\#15](https://github.com/bodgit/puppet-openldap/issues/15)

## [v1.1.0](https://github.com/bodgit/puppet-openldap/tree/v1.1.0) (2015-07-02)
[Full Changelog](https://github.com/bodgit/puppet-openldap/compare/v1.0.0...v1.1.0)

**Implemented enhancements:**

- refactor to use rspec-puppet-facts [\#12](https://github.com/bodgit/puppet-openldap/issues/12)
- Add support for auditlog [\#14](https://github.com/bodgit/puppet-openldap/issues/14)

## [v1.0.0](https://github.com/bodgit/puppet-openldap/tree/v1.0.0) (2015-06-22)
**Implemented enhancements:**

- Support setting security options [\#8](https://github.com/bodgit/puppet-openldap/issues/8)
- Support creating an object from LDIF [\#6](https://github.com/bodgit/puppet-openldap/issues/6)
- Allow control of attribute purging [\#5](https://github.com/bodgit/puppet-openldap/issues/5)
- Autorequire database directory [\#4](https://github.com/bodgit/puppet-openldap/issues/4)
- Automatically prune out attribute keys with a nil value [\#2](https://github.com/bodgit/puppet-openldap/issues/2)

**Fixed bugs:**

- Using add/delete doesn't always work [\#3](https://github.com/bodgit/puppet-openldap/issues/3)
- Autorequire previous sibling object [\#1](https://github.com/bodgit/puppet-openldap/issues/1)



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*