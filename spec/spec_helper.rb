# To run coverage via travis
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'spec'
end

# To run it manually via Rake
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
  SimpleCov.start
end

require 'dotenv'
Dotenv.load

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'fileutils'
require 'tmpdir'
require 'logger'
require 'rspec/its'
require 'neo4j/core'
require 'neo4j/core/query'
require 'ostruct'
require 'openssl'
require 'neo4j_ruby_driver' if RUBY_PLATFORM =~ /java/

if RUBY_PLATFORM == 'java'
  # for some reason this is not impl. in JRuby
  class OpenStruct
    def [](key)
      send(key)
    end
  end

end

Dir["#{File.dirname(__FILE__)}/shared_examples/**/*.rb"].each { |f| require f }

EMBEDDED_DB_PATH = File.join(Dir.tmpdir, 'neo4j-core-java')

require "#{File.dirname(__FILE__)}/helpers"

require 'neo4j/core/cypher_session'
require 'neo4j/core/cypher_session/adaptors/http'
require 'neo4j/core/cypher_session/adaptors/bolt'
require 'neo4j/core/cypher_session/adaptors/embedded'
require 'neo4j_spec_helpers'

module Neo4jSpecHelpers
  # def log_queries!
  #   Neo4j::Server::CypherSession.log_with(&method(:puts))
  #   Neo4j::Core::CypherSession::Adaptors::Base.subscribe_to_query(&method(:puts))
  #   Neo4j::Core::CypherSession::Adaptors::HTTP.subscribe_to_request(&method(:puts))
  #   Neo4j::Core::CypherSession::Adaptors::Bolt.subscribe_to_request(&method(:puts))
  #   Neo4j::Core::CypherSession::Adaptors::Embedded.subscribe_to_transaction(&method(:puts))
  # end

  def current_transaction
    Neo4j::Transaction.current_for(Neo4j::Session.current)
  end

  # rubocop:disable Style/GlobalVars
  def expect_http_requests(count)
    start_count = $expect_http_request_count
    yield
    expect($expect_http_request_count - start_count).to eq(count)
  end

  def setup_http_request_subscription
    $expect_http_request_count = 0

    Neo4j::Core::CypherSession::Adaptors::HTTP.subscribe_to_request do |_message|
      $expect_http_request_count += 1
    end
  end
  # rubocop:enable Style/GlobalVars

  def test_bolt_url
    ENV['NEO4J_BOLT_URL']
  end

  def test_bolt_adaptor(url, extra_options = {})
    options = {}
    options[:logger_level] = Logger::DEBUG if ENV['DEBUG']

    options[:ssl] = false

    Neo4j::Core::CypherSession::Adaptors::Bolt.new(url, options.merge(extra_options))
  end

  def test_http_url
    ENV['NEO4J_URL']
  end

  def test_http_adaptor(url, extra_options = {})
    options = {}
    options[:logger_level] = Logger::DEBUG if ENV['DEBUG']

    Neo4j::Core::CypherSession::Adaptors::HTTP.new(url, options.merge(extra_options))
  end

  def delete_db(session)
    session.query('MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n, r')
  end
end

require 'dryspec/helpers'

FileUtils.rm_rf(EMBEDDED_DB_PATH)

RSpec.configure do |config|
  config.include Neo4jSpecHelpers
  config.extend DRYSpec::Helpers
  # config.include Helpers

  config.exclusion_filter = {
    bolt: lambda do
      ENV['NEO4J_VERSION'].to_s.match(/^(community|enterprise)-2\./)
    end
  }
end
