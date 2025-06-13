# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class AskResponse < BaseResponse
      def answer
        raw_data[:answer]
      end

      def confidence
        raw_data[:confidence]
      end

      def context
        raw_data[:context] || []
      end
    end
  end
end
