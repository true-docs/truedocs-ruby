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

      def result
        raw_data[:result]
      end

      def progress
        raw_data[:progress]
      end

      def created_at
        timestamp = raw_data[:createdAt] || raw_data[:created_at]
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
        status == "pending"
      end

      def in_progress?
        status == "in_progress"
      end

      def completed?
        status == "completed"
      end

      def failed?
        status == "failed"
      end
    end
  end
end
