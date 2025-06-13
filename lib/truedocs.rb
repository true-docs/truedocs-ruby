# frozen_string_literal: true

require_relative "truedocs/version"
require_relative "truedocs/configuration"
require_relative "truedocs/errors"
require_relative "truedocs/client"

# Require all response classes
require_relative "truedocs/responses/base_response"
require_relative "truedocs/responses/classification_response"
require_relative "truedocs/responses/extraction_response"
require_relative "truedocs/responses/verification_response"
require_relative "truedocs/responses/job_response"
require_relative "truedocs/responses/match_response"
require_relative "truedocs/responses/query_response"
require_relative "truedocs/responses/ask_response"
require_relative "truedocs/responses/validation_response"

# Require utilities
require_relative "truedocs/utils/file_handler"

module Truedocs
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def new(**options)
      Client.new(**options)
    end
  end
end
