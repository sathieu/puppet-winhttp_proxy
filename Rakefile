require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

#Puppet lint configuration
PuppetLint.configuration.send("disable_80chars")

task :default => [:test]

desc 'Run RSpec'
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = 'spec/{unit}/**/*.rb'
  #t.rspec_opts = ['--color']
end
