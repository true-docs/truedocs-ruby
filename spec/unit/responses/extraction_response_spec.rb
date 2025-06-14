# frozen_string_literal: true

RSpec.describe Truedocs::Responses::ExtractionResponse do
  describe "successful extraction response with lines" do
    let(:lines_data) do
      {
        success: true,
        lines: [
          "INSTITUTO NACIONAL ELECTORAL",
          "CREDENCIAL PARA VOTAR",
          "NOMBRE: JUAN PEREZ GARCIA",
          "DOMICILIO: CALLE REFORMA 123",
          "FECHA DE NACIMIENTO: 15/03/1985"
        ]
      }
    end

    subject { described_class.new(lines_data) }

    it "returns lines array" do
      lines = subject.lines
      expect(lines).to be_an(Array)
      expect(lines.length).to eq(5)
      expect(lines.first).to eq("INSTITUTO NACIONAL ELECTORAL")
      expect(lines.last).to eq("FECHA DE NACIMIENTO: 15/03/1985")
    end

    it "returns empty fields" do
      expect(subject.fields).to be_empty
    end
  end

  describe "successful extraction response with fields" do
    let(:fields_data) do
      {
        success: true,
        fields: {
          nombre: "JUAN PEREZ GARCIA",
          fecha_nacimiento: "15/03/1985",
          domicilio: "CALLE REFORMA 123"
        }
      }
    end

    subject { described_class.new(fields_data) }

    it "returns fields hash" do
      fields = subject.fields
      expect(fields[:nombre]).to eq("JUAN PEREZ GARCIA")
      expect(fields[:fecha_nacimiento]).to eq("15/03/1985")
      expect(fields[:domicilio]).to eq("CALLE REFORMA 123")
    end

    it "returns empty lines" do
      expect(subject.lines).to be_empty
    end
  end

  describe "empty extraction response" do
    let(:empty_data) do
      {
        success: true,
        lines: [],
        fields: {}
      }
    end

    subject { described_class.new(empty_data) }

    it "handles empty extraction" do
      expect(subject.lines).to be_empty
      expect(subject.fields).to be_empty
    end
  end

  describe "missing fields" do
    let(:minimal_data) { { success: true } }
    subject { described_class.new(minimal_data) }

    it "provides default values for missing fields" do
      expect(subject.lines).to eq([])
      expect(subject.fields).to eq({})
    end
  end

  describe "shared examples" do
    let(:data) { { success: true, lines: [] } }
    subject { described_class.new(data) }

    include_examples "a successful response" do
      let(:response) { subject }
    end

    include_examples "a response with data" do
      let(:response) { subject }
    end
  end
end 