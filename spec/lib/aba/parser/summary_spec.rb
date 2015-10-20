# encoding: UTF-8

require "spec_helper"

describe Aba::Parser::Summary do
  it { is_expected.to be_a_kind_of(Aba::Parser::Line) }

  it "defines RECORD_TYPES constant with Record Type values" do
    expect(described_class::RECORD_TYPES).to eq(['7'])
  end

  describe ".record_types" do
    it "returns value defined in RECORD_TYPES constant" do
      expect(described_class.record_types).to eq(described_class::RECORD_TYPES)
    end
  end

  describe ".parse_line" do
    it "returns parsed given line" do
      line = "7999-999            000001234500000678900000080235                        000012                                        "
      parsed_line = {
        bsb: "999-999",
        net_total_amount: 12345,
        credit_total_amount: 67890,
        debit_total_amount: 80235,
        count: 12
      }

      expect(described_class.parse(line)).to eq(parsed_line)
    end
  end
end
