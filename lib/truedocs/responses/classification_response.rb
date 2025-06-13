# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class ClassificationResponse < BaseResponse
      def document_type
        raw_data[:documentType] || raw_data[:document_type]
      end

      def confidence
        raw_data[:confidence]
      end

      def predictions
        raw_data[:predictions] || []
      end
    end
  end
end
