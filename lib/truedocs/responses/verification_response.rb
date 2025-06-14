# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class VerificationResponse < BaseResponse
      def verifications
        verifications_data = raw_data[:verifications] || {}
        # Ensure we can access both string and symbol keys
        verifications_data.is_a?(Hash) ? verifications_data.transform_keys(&:to_sym) : verifications_data
      end

      def found
        found_data = verifications[:found] || {}
        found_data.is_a?(Hash) ? found_data.transform_keys(&:to_sym) : found_data
      end

      def not_found
        verifications[:notFound] || verifications[:not_found] || []
      end

      def messages
        verifications[:messages] || []
      end

      def verified?
        found.any? && not_found.empty?
      end
    end
  end
end
