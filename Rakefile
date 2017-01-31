require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'rake/clean'

CLEAN.include('spec/fixtures/manifests', 'spec/fixtures/modules')
CLOBBER.include('.tmp', '.librarian', '.vagrant', 'Puppetfile.lock', 'log', 'junit')

task :spec => []; Rake::Task[:spec].clear
task :spec do
  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec_standalone].invoke
end

task :librarian_spec_prep do
  sh 'librarian-puppet install --path=spec/fixtures/modules/'
end
task :spec_prep => :librarian_spec_prep

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp", "vendor/**/*.pp"]
  config.log_format = '%{path}:%{line}:%{check}:%{KIND}:%{message}'
  config.disable_checks = ['class_inherits_from_params_class']
  config.fail_on_warnings = true
end

task :test => [
  'syntax',
  'spec',
  'lint',
]

PuppetSyntax.exclude_paths = ['pkg/**/*', 'spec/**/*', 'vendor/**/*']
