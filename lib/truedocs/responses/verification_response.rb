# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class VerificationResponse < BaseResponse
      def verifications
        raw_data[:verifications] || {}
      end

      def found
        verifications[:found] || {}
      end

      def not_found
        verifications[:notFound] || []
      end

      def messages
        verifications[:messages] || []
      end

      def verified?
        !found.empty?
      end
    end
  end
end
