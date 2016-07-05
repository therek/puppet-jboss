source ENV['GEM_SOURCE'] || 'https://rubygems.org'

eval(IO.read(File.join(File.dirname(__FILE__), 'Gemfile.ruby19')), binding) if RUBY_VERSION < '2.0.0' and RUBY_VERSION >= '1.9.0'
eval(IO.read(File.join(File.dirname(__FILE__), 'Gemfile.ruby18')), binding) if RUBY_VERSION < '1.9.0'
eval(IO.read(File.join(File.dirname(__FILE__), 'Gemfile.local')), binding) if File.exists?('Gemfile.local')

group :test do
  gem 'rake',                           :require => false unless dependencies.map {|dep| dep.name}.include?('rake')
  # TODO: Remove this explicitly pinned version by the time ticket gh-org/puppet-jboss#84 is closed.
  gem 'rspec-puppet', '2.3.2',          :require => false
  gem 'puppetlabs_spec_helper',         :require => false
  gem 'puppet-lint',                    :require => false
  gem 'metadata-json-lint',             :require => false
  # This package drops support for 1.8
  gem 'json', '1.8.3',                  :require => false
  gem 'os',                             :require => false
  gem 'specinfra', '2.59.0',            :require => false
  gem 'net-ssh', '2.9.4',               :require => false
  # This package drops support for 1.8
  gem 'json_pure', '1.8.3',             :require => false
  # Mime-types 3.0 drops support for Ruby 1.8
  gem 'mime-types', '2.99.2',           :require => false

  gem 'beaker',                         :require => false
  gem 'beaker-rspec',                   :require => false
  gem 'docker-api',                     :require => false
  gem 'coveralls',                      :require => false
  gem 'codeclimate-test-reporter',      :require => false
  gem 'simplecov',                      :require => false
  if facterver = ENV['FACTER_VERSION']
    gem 'facter', facterver,            :require => false
  else
    gem 'facter',                       :require => false
  end
  gem 'puppet', '~> 3.0',               :require => false
  gem 'ruby-augeas',                    :require => false
  gem 'augeas',                         :require => false
end

group :development do
  gem 'inch',                           :require => false
  gem 'vagrant-wrapper',                :require => false
  gem 'travis',                         :require => false
  gem 'puppet-blacksmith',              :require => false
  gem 'guard-rake',                     :require => false
  gem 'pry-byebug',                     :require => false
end

# vim:ft=ruby
