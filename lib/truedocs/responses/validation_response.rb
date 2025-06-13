# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class ValidationResponse < BaseResponse
      def validation_result
        raw_data[:validationResult] || raw_data[:validation_result]
      end

      def valid?
        [true, "valid"].include?(validation_result)
      end

      def validation_details
        raw_data[:validationDetails] || raw_data[:validation_details] || {}
      end

      def warnings
        raw_data[:warnings] || []
      end
    end
  end
end
