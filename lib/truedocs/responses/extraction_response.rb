# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class ExtractionResponse < BaseResponse
      def lines
        raw_data[:lines] || []
      end

      def fields
        fields_data = raw_data[:fields] || {}
        # Ensure we can access both string and symbol keys
        fields_data.is_a?(Hash) ? fields_data.transform_keys(&:to_sym) : fields_data
      end
    end
  end
end
