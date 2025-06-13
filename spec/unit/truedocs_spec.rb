# frozen_string_literal: true

RSpec.describe Truedocs do
  it "has a version number" do
    expect(Truedocs::VERSION).not_to be_nil
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(Truedocs.configuration).to be_a(Truedocs::Configuration)
    end
  end

  describe ".configure" do
    it "yields the configuration object" do
      expect { |b| Truedocs.configure(&b) }.to yield_with_args(Truedocs.configuration)
    end

    it "allows setting configuration options" do
      Truedocs.configure do |config|
        config.api_key = "new_key"
        config.timeout = 120
      end

      expect(Truedocs.configuration.api_key).to eq("new_key")
      expect(Truedocs.configuration.timeout).to eq(120)
    end
  end

  describe ".reset_configuration!" do
    it "resets the configuration to defaults" do
      Truedocs.configure { |config| config.timeout = 120 }
      Truedocs.reset_configuration!

      expect(Truedocs.configuration.timeout).to eq(60)
    end
  end

  describe ".new" do
    it "returns a new client instance" do
      client = Truedocs.new(api_key: "test_key")
      expect(client).to be_a(Truedocs::Client)
    end
  end
end
