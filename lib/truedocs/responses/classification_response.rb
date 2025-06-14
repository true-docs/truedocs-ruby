# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class ClassificationResponse < BaseResponse
      def prediction
        raw_data[:prediction] || {}
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
