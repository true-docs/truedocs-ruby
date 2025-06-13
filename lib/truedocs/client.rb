# frozen_string_literal: true

require "faraday"
require "faraday/multipart"
require "faraday/retry"
require_relative "resources/document"
require_relative "resources/job"
require_relative "resources/validation"

module Truedocs
  class Client
    include Truedocs::Resources::Document
    include Truedocs::Resources::Job
    include Truedocs::Resources::Validation

    DOCUMENT_TYPES = {
      constancia_situacion_fiscal: "constancia_de_situacion_fiscal",
      ine_reverso: "ine_reverso"
    }.freeze

    VALIDATION_TYPES = {
      did_expire: "DidExpire",
      is_recent: "IsRecent"
    }.freeze

    JOB_STATUSES = %w[pending in_progress completed failed].freeze

    def initialize(api_key: nil, **options)
      @config = build_configuration(api_key: api_key, **options)
      validate_configuration!
      @connection = build_connection
    end

    private

    attr_reader :config, :connection

    def build_configuration(api_key: nil, **options)
      config = Truedocs.configuration.dup
      config.api_key = api_key if api_key
      options.each { |key, value| config.public_send("#{key}=", value) if config.respond_to?("#{key}=") }
      config
    end

    def validate_configuration!
      raise ConfigurationError, "API key is required" unless config.valid?
    end

    def build_connection
      Faraday.new(url: config.base_url) do |conn|
        conn.request :multipart
        conn.request :json
        conn.request :retry, max: config.retries, interval: 0.5, backoff_factor: 2

        conn.response :json, content_type: /\bjson$/
        conn.response :logger, config.logger, bodies: true if config.logger.level <= Logger::DEBUG

        conn.adapter config.adapter
        conn.options.timeout = config.timeout
        conn.headers = default_headers
      end
    end

    def default_headers
      {
        "X-API-Version" => config.api_version,
        "X-API-Key" => config.api_key,
        "Accept" => "application/json",
        "User-Agent" => "truedocs-ruby/#{Truedocs::VERSION} (Ruby #{RUBY_VERSION})"
      }
    end

    def perform_request(method, endpoint, payload: nil, **options)
      response = connection.public_send(method, endpoint) do |req|
        req.body = payload if payload
        options.each { |key, value| req.options[key] = value }
      end

      handle_response(response)
    rescue Faraday::TimeoutError => e
      raise TimeoutError, "Request timeout: #{e.message}"
    rescue Faraday::ConnectionFailed => e
      raise NetworkError, "Connection failed: #{e.message}"
    end

    def handle_response(response)
      case response.status
      when 200..299
        response.body
      when 401
        raise AuthenticationError, "Invalid API key"
      when 403
        raise AuthorizationError, "Access forbidden"
      when 422
        raise ValidationError, extract_error_message(response)
      when 429
        raise RateLimitError, "Rate limit exceeded"
      when 500..599
        raise ServerError, "Server error: #{response.status}"
      else
        raise Error, "HTTP #{response.status}: #{extract_error_message(response)}"
      end
    end

    def extract_error_message(response)
      return response.reason_phrase unless response.body.is_a?(Hash)

      response.body.dig("error", "message") || response.body["message"] || response.reason_phrase
    end
  end
end
