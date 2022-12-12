source 'https://rubygems.org'

gemspec

# gem 'neo4j-advanced',   '>= 1.8.1', '< 2.0', :require => false
# gem 'neo4j-enterprise', '>= 1.8.1', '< 2.0', :require => false

gem 'tins', '< 1.7' if RUBY_VERSION.to_f < 2.0

gem 'neo4j-rake_tasks', github: 'vishvish/neo4j-rake_tasks', branch: 'master'

group 'development' do
  if RUBY_PLATFORM =~ /java/
    gem 'neo4j-ruby-driver', path: '../neo4j-ruby-driver' if ENV['USE_LOCAL_DRIVER']
  else
    gem 'guard-rspec', require: false
  end
  if RUBY_VERSION.to_f < 2.0
    gem 'overcommit', '< 0.35.0'
    gem 'term-ansicolor', '< 1.4'
  else
    gem 'overcommit'
  end
end

group 'test' do
  gem 'activesupport'
  gem 'coveralls', require: false
  gem 'dotenv'
  gem 'rspec'
  gem 'rspec-its'
  gem 'simplecov-html', require: false
end
