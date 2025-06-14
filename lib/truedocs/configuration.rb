# frozen_string_literal: true

require "logger"

module Truedocs
  class Configuration
    attr_accessor :api_key, :base_url, :api_version, :timeout, :retries, :logger, :adapter

    def initialize
      @api_key = ENV.fetch("TRUEDOCS_API_KEY", nil)
      @base_url = ENV.fetch("TRUEDOCS_URL", "https://api.truedocs.mx")
      @api_version = "2"
      @timeout = 60
      @retries = 3
      @logger = Logger.new($stdout, level: Logger::WARN)
      @adapter = :net_http
    end

    def valid?
      !api_key.nil? && !api_key.empty?
    end
  end
end
