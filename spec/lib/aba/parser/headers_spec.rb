# encoding: UTF-8

require "spec_helper"

describe Aba::Parser::Headers do
  it { is_expected.to be_a_kind_of(Aba::Parser::Line) }

  it "defines RECORD_TYPES constant with Record Type values" do
    expect(described_class::RECORD_TYPES).to eq(['0'])
  end

  describe ".record_types" do
    it "returns value defined in RECORD_TYPES constant" do
      expect(described_class.record_types).to eq(described_class::RECORD_TYPES)
    end
  end

  describe ".handle" do
    let(:line) { instance_double(String) }

    it "parses given line" do
      allow(Aba::Batch).to receive(:new)

      expect(described_class).to receive(:parse).with(line)

      described_class.handle(line)
    end

    it "initializes new batch with parsed line" do
      parsed_line = double('parsed line')
      allow(described_class).to receive(:parse).and_return(parsed_line)

      expect(Aba::Batch).to receive(:new).with(parsed_line)

      described_class.handle(line)
    end

    it "returns initialized batch" do
      batch = double('batch')

      allow(described_class).to receive(:parse)
      allow(Aba::Batch).to receive(:new).and_return(batch)

      expect(described_class.handle(line)).to eq(batch)
    end
  end

  describe ".parse_line" do
    it "returns result of parsing given line" do
      line = "0123-345          01WPC       John Doe                  466364Payroll     210915                                        "
      parsed_line = {
        bsb: "123-345",
        financial_institution: "WPC",
        user_name: "John Doe",
        user_id: "466364",
        description: "Payroll",
        process_at: "210915"
      }

      expect(described_class.parse(line)).to eq(parsed_line)
    end
  end
end
