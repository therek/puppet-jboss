source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'rake',                           :require => false unless dependencies.map {|dep| dep.name}.include?('rake')
  # TODO: Remove this explicitly pinned version by the time ticket gh-org/puppet-jboss#84 is closed.
  gem 'rspec-puppet', '2.3.2',          :require => false
  gem 'puppetlabs_spec_helper',         :require => false
  gem 'puppet-lint',                    :require => false
  gem 'metadata-json-lint',             :require => false
  gem 'os',                             :require => false
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
  gem 'pry-byebug',                     :require => false
end

# vim:ft=ruby
