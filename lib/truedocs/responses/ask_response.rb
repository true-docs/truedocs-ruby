# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class AskResponse < BaseResponse
      def response
        raw_data[:response]
      end
    end
  end
end
