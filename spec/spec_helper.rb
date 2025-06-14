# frozen_string_literal: true

require "bundler/setup"
require "dotenv/load"
require "webmock/rspec"
require "vcr"
require "simplecov"

# Start SimpleCov
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vendor/"

  add_group "Resources", "lib/truedocs/resources"
  add_group "Responses", "lib/truedocs/responses"
  add_group "Utils", "lib/truedocs/utils"
end

require "truedocs"

# Configure WebMock
WebMock.disable_net_connect!(allow_localhost: true)

# Configure VCR
VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data("<API_KEY>") { ENV["TRUEDOCS_API_KEY"] }
  config.default_cassette_options = {
    record: ENV["VCR_RECORD_MODE"]&.to_sym || :once,
    match_requests_on: %i[method uri]
  }
  
  # Allow real HTTP connections when recording
  config.allow_http_connections_when_no_cassette = true if ENV["VCR_RECORD_MODE"] == "new_episodes"
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on Module and main
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clear configuration before each test
  config.before(:each) do
    Truedocs.reset_configuration!
    Truedocs.configure do |truedocs_config|
      truedocs_config.api_key = "test_api_key"
      truedocs_config.base_url = "https://api.truedocs.mx"
    end
  end

  # Load support files
  Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }
end
