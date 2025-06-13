# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class QueryResponse < BaseResponse
      def answer
        raw_data[:answer]
      end

      def confidence
        raw_data[:confidence]
      end

      def sources
        raw_data[:sources] || []
      end
    end
  end
end
