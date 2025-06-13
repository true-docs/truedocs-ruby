# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class ExtractionResponse < BaseResponse
      def extracted_fields
        raw_data[:extractedFields] || raw_data[:extracted_fields] || {}
      end

      def confidence_scores
        raw_data[:confidenceScores] || raw_data[:confidence_scores] || {}
      end

      def text_blocks
        raw_data[:textBlocks] || raw_data[:text_blocks] || []
      end
    end
  end
end
