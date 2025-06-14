# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class ValidationResponse < BaseResponse
      def validation
        raw_data[:validation] || {}
      end

      def validation_type
        validation[:type]
      end

      def match
        validation[:match]
      end

      def confidence
        validation[:confidence]
      end

      def is_valid
        validation[:isValid]
      end

      def valid?
        is_valid == true
      end
    end
  end
end
