source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :development, :test do
  gem 'rake',                                             :require => false
  gem 'rspec',                                            :require => false
  gem 'rspec-puppet', '>= 2.2.0',                         :require => false
  gem 'puppetlabs_spec_helper',                           :require => false
  gem 'metadata-json-lint',                               :require => false
  gem 'puppet-lint', '>= 1.1.0',                          :require => false
  gem 'puppet-lint-unquoted_string-check',                :require => false
  gem 'puppet-lint-empty_string-check',                   :require => false
  gem 'puppet-lint-spaceship_operator_without_tag-check', :require => false
  gem 'puppet-lint-variable_contains_upcase',             :require => false
  gem 'puppet-lint-absolute_classname-check',             :require => false
  gem 'puppet-lint-undef_in_function-check',              :require => false
  gem 'puppet-lint-leading_zero-check',                   :require => false
  gem 'puppet-lint-trailing_comma-check',                 :require => false
  gem 'puppet-lint-file_ensure-check',                    :require => false
  gem 'puppet-lint-version_comparison-check',             :require => false
  gem 'puppet-lint-fileserver-check',                     :require => false
  gem 'puppet-lint-file_source_rights-check',             :require => false
  gem 'puppet-lint-alias-check',                          :require => false
  gem 'librarian-puppet',                                 :require => false
  gem 'beaker', '>= 2.18.2',                              :require => false
  gem 'beaker-rspec',                                     :require => false
  gem 'rspec-puppet-facts', ['>= 0.11.0', '< 1.0.0'],     :require => false
  gem 'coveralls',                                        :require => false
  gem 'specinfra', '>= 2.42.1',                           :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
