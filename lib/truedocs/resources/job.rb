# frozen_string_literal: true

require_relative "../responses/job_response"

module Truedocs
  module Resources
    module Job
      def get_job_status(job_id, **options)
        response = perform_request(:get, "/jobs/#{job_id}", **options)
        Responses::JobResponse.new(response)
      end

      alias job_status get_job_status

      def poll_job(job_id, interval: 5, timeout: 90)
        start_time = Time.now

        loop do
          job = get_job_status(job_id)

          # Yield to block if provided for custom handling
          yield(job) if block_given?

          case job.status
          when "completed"
            return job
          when "failed"
            raise Error, job.error_message || "Job failed"
          when "pending", "in_progress"
            raise TimeoutError, "Polling timeout exceeded after #{timeout} seconds" if Time.now - start_time > timeout

            sleep interval
          else
            raise Error, "Unknown job status: #{job.status}"
          end
        end
      end

      def wait_for_job(job_id, **options)
        poll_job(job_id, **options)
      end
    end
  end
end
