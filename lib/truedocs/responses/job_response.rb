# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class JobResponse < BaseResponse
      def job_id
        raw_data[:jobId] || raw_data[:job_id]
      end

      def status
        raw_data[:status]
      end

      def document_type
        raw_data[:documentType] || raw_data[:document_type]
      end

      def result
        raw_data[:result]
      end

      def progress
        raw_data[:progress]
      end

      def error
        raw_data[:error]
      end

      def created_at
        timestamp = raw_data[:createdAt] || raw_data[:created_at]
        timestamp ? Time.parse(timestamp) : nil
      rescue ArgumentError
        nil
      end

      def updated_at
        timestamp = raw_data[:updatedAt] || raw_data[:updated_at]
        timestamp ? Time.parse(timestamp) : nil
      rescue ArgumentError
        nil
      end

      def completed_at
        timestamp = raw_data[:completedAt] || raw_data[:completed_at]
        timestamp ? Time.parse(timestamp) : nil
      rescue ArgumentError
        nil
      end

      def pending?
        status == "PENDING"
      end

      def in_progress?
        status == "IN_PROGRESS"
      end

      def completed?
        status == "COMPLETED"
      end

      def failed?
        status == "FAILED"
      end
    end
  end
end
