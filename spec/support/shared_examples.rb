# frozen_string_literal: true

RSpec.shared_examples "a successful response" do
  it "returns a successful response" do
    expect(response).to be_success
    expect(response).not_to be_error
  end
end

RSpec.shared_examples "an error response" do
  it "returns an error response" do
    expect(response).to be_error
    expect(response).not_to be_success
  end
end

RSpec.shared_examples "a response with data" do
  it "contains response data" do
    expect(response.raw_data).to be_a(Hash)
    expect(response.to_h).to eq(response.raw_data)
  end
end

RSpec.shared_examples "handles file uploads" do
  context "with file path" do
    let(:file) { "spec/fixtures/sample.pdf" }

    before do
      allow(File).to receive(:exist?).with(file).and_return(true)
      allow(File).to receive(:size).with(file).and_return(1024)
    end

    it "accepts file path" do
      expect { subject }.not_to raise_error
    end
  end

  context "with File object" do
    let(:file) { File.open("spec/fixtures/sample.pdf", "rb") }

    before do
      allow(file).to receive(:read).and_return("fake content")
      allow(file).to receive(:rewind)
    end

    it "accepts File object" do
      expect { subject }.not_to raise_error
    end
  end
end
