# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class MatchResponse < BaseResponse
      # New API methods for string search within document
      def confidence
        raw_data[:confidence]
      end

      def matches
        match_results = raw_data[:matches] || []
        match_results.map do |result|
          {
            line: result[:line] || result["line"],
            similarity: result[:similarity] || result["similarity"]
          }
        end
      end

      def lines
        matches.map { |match| match[:line] }
      end

      def similarities
        matches.map { |match| match[:similarity] }
      end

      def top_match
        matches.first
      end

      def has_matches?
        !matches.empty?
      end

      def average_similarity
        similarities_array = similarities.compact
        return 0.0 if similarities_array.empty?
        similarities_array.sum.to_f / similarities_array.length
      end

      def matches?
        has_matches?
      end
    end
  end
end
