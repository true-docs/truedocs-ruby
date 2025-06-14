# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class ClassificationResponse < BaseResponse
      def prediction
        pred = raw_data[:prediction] || {}
        # Ensure we can access both string and symbol keys
        pred.is_a?(Hash) ? pred.transform_keys(&:to_sym) : pred
      end

      def document_type
        prediction[:documentType] || prediction[:document_type] || "unknown"
      end

      def confidence
        prediction[:confidence]
      end

      def country
        prediction[:country]
      end

      def entity
        prediction[:entity]
      end

      def entity_short_name
        prediction[:entityShortName] || prediction[:entity_short_name]
      end

      def unknown?
        document_type == "unknown"
      end
    end
  end
end
