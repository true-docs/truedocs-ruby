# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class ExtractionResponse < BaseResponse
      def lines
        raw_data[:lines] || []
      end

      def fields
        raw_data[:fields] || {}
      end
    end
  end
end
