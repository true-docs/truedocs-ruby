# frozen_string_literal: true

module Truedocs
  class Error < StandardError
    attr_reader :response, :status_code

    def initialize(message = nil, response: nil)
      @response = response
      @status_code = response&.status
      super(message)
    end
  end

  class ConfigurationError < Error; end
  class AuthenticationError < Error; end
  class AuthorizationError < Error; end
  class ValidationError < Error; end
  class RateLimitError < Error; end
  class TimeoutError < Error; end
  class ServerError < Error; end
  class NetworkError < Error; end
  class UnsupportedFileTypeError < Error; end
  class FileTooLargeError < Error; end
end
