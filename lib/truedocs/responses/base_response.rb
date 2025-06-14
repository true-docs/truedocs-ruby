# frozen_string_literal: true

module Truedocs
  module Responses
    class BaseResponse
      attr_reader :raw_data

      def initialize(data)
        @raw_data = data.is_a?(Hash) ? data.transform_keys(&:to_sym) : data
      end

      def success?
        # V2 API format: check status field or absence of error
        if raw_data.key?(:status)
          raw_data[:status] == "success"
        else
          # Fallback: success if no error present and not explicitly marked as failed
          !raw_data.key?(:error) && raw_data[:success] != false
        end
      end

      def error?
        !success?
      end

      def error_message
        raw_data[:error] || raw_data[:message]
      end

      def to_h
        raw_data
      end

      def to_json(*args)
        raw_data.to_json(*args)
      end

      private

      def method_missing(method_name, *args, &block)
        if raw_data.respond_to?(method_name)
          raw_data.public_send(method_name, *args, &block)
        elsif raw_data.key?(method_name)
          raw_data[method_name]
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        raw_data.respond_to?(method_name) || raw_data.key?(method_name) || super
      end
    end
  end
end
