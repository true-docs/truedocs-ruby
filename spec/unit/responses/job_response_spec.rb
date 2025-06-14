# frozen_string_literal: true

RSpec.describe Truedocs::Responses::JobResponse do
  describe "completed job response" do
    let(:job_data) do
      {
        success: true,
        jobId: "job_123456789",
        status: "COMPLETED",
        progress: 100,
        result: {
          verificationResult: "verified",
          confidence: 0.95
        },
        createdAt: "2024-01-15T10:30:00Z",
        completedAt: "2024-01-15T10:32:15Z"
      }
    end

    subject { described_class.new(job_data) }

    it "returns job id" do
      expect(subject.job_id).to eq("job_123456789")
    end

    it "returns status" do
      expect(subject.status).to eq("COMPLETED")
    end

    it "returns progress" do
      expect(subject.progress).to eq(100)
    end

    it "returns result" do
      result = subject.result
      expect(result[:verificationResult]).to eq("verified")
      expect(result[:confidence]).to eq(0.95)
    end

    it "returns created_at timestamp" do
      expect(subject.created_at).to be_a(Time)
      expect(subject.created_at.iso8601).to eq("2024-01-15T10:30:00Z")
    end

    it "returns completed_at timestamp" do
      expect(subject.completed_at).to be_a(Time)
      expect(subject.completed_at.iso8601).to eq("2024-01-15T10:32:15Z")
    end

    it "returns correct status checks" do
      expect(subject.pending?).to be false
      expect(subject.in_progress?).to be false
      expect(subject.completed?).to be true
      expect(subject.failed?).to be false
    end

    it "handles snake_case keys" do
      snake_case_data = {
        success: true,
        job_id: "job_987654321",
        created_at: "2024-01-15T10:30:00Z"
      }
      
      response = described_class.new(snake_case_data)
      expect(response.job_id).to eq("job_987654321")
      expect(response.created_at).to be_a(Time)
    end
  end

  describe "pending job response" do
    let(:pending_data) do
      {
        success: true,
        jobId: "job_pending_123",
        status: "PENDING",
        progress: 0,
        createdAt: "2024-01-15T10:30:00Z"
      }
    end

    subject { described_class.new(pending_data) }

    it "returns correct status checks for pending job" do
      expect(subject.pending?).to be true
      expect(subject.in_progress?).to be false
      expect(subject.completed?).to be false
      expect(subject.failed?).to be false
    end

    it "returns nil for completed_at when not completed" do
      expect(subject.completed_at).to be_nil
    end
  end

  describe "in_progress job response" do
    let(:in_progress_data) do
      {
        success: true,
        jobId: "job_progress_123",
        status: "IN_PROGRESS",
        progress: 45,
        createdAt: "2024-01-15T10:30:00Z"
      }
    end

    subject { described_class.new(in_progress_data) }

    it "returns correct status checks for in_progress job" do
      expect(subject.pending?).to be false
      expect(subject.in_progress?).to be true
      expect(subject.completed?).to be false
      expect(subject.failed?).to be false
    end
  end

  describe "failed job response" do
    let(:failed_data) do
      {
        success: true,
        jobId: "job_failed_123",
        status: "FAILED",
        progress: 0,
        error: "Document processing failed",
        createdAt: "2024-01-15T10:30:00Z",
        completedAt: "2024-01-15T10:31:00Z"
      }
    end

    subject { described_class.new(failed_data) }

    it "returns correct status checks for failed job" do
      expect(subject.pending?).to be false
      expect(subject.in_progress?).to be false
      expect(subject.completed?).to be false
      expect(subject.failed?).to be true
    end
  end

  describe "invalid timestamp handling" do
    let(:invalid_timestamp_data) do
      {
        success: true,
        jobId: "job_invalid_time",
        status: "COMPLETED",
        createdAt: "invalid-timestamp",
        completedAt: "also-invalid"
      }
    end

    subject { described_class.new(invalid_timestamp_data) }

    it "handles invalid timestamps gracefully" do
      expect(subject.created_at).to be_nil
      expect(subject.completed_at).to be_nil
    end
  end

  describe "missing fields" do
    let(:minimal_data) { { success: true } }
    subject { described_class.new(minimal_data) }

    it "provides default values for missing fields" do
      expect(subject.job_id).to be_nil
      expect(subject.status).to be_nil
      expect(subject.result).to be_nil
      expect(subject.progress).to be_nil
      expect(subject.created_at).to be_nil
      expect(subject.completed_at).to be_nil
    end
  end

  describe "shared examples" do
    let(:data) { { status: "success", jobId: "test_job", jobStatus: "COMPLETED" } }
    subject { described_class.new(data) }

    include_examples "a successful response" do
      let(:response) { subject }
    end

    include_examples "a response with data" do
      let(:response) { subject }
    end
  end
end 