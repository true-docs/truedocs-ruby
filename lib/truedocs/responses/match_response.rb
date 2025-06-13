# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class MatchResponse < BaseResponse
      def match_score
        raw_data[:matchScore] || raw_data[:match_score]
      end

      def matches?
        match_score && match_score > 0.5
      end

      def matched_fields
        raw_data[:matchedFields] || raw_data[:matched_fields] || []
      end

      def differences
        raw_data[:differences] || []
      end
    end
  end
end
