# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class VerificationResponse < BaseResponse
      def verification_result
        raw_data[:verificationResult] || raw_data[:verification_result]
      end

      def verified?
        verification_result == "verified" || raw_data[:verified] == true
      end

      def verification_details
        raw_data[:verificationDetails] || raw_data[:verification_details] || {}
      end

      def status
        raw_data[:status]
      end
    end
  end
end
