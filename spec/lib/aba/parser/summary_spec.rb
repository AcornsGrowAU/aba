# encoding: UTF-8

require "spec_helper"

describe Aba::Parser::Summary do
  it { is_expected.to be_a_kind_of(Aba::Parser::Line) }

  describe ".valid_record_types" do
    it "returns valid value for summary Record Type" do
      expect(described_class.valid_record_types).to eq(["7"])
    end
  end

  describe ".valid_line_length" do
    it "returns valid number of characters in summary line" do
      expect(described_class.valid_line_length).to eq(120)
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

  describe ".prepare_record" do
    let(:arguments) { double('arguments') }

    it "just returns given arguments" do
      expect(described_class.prepare_record(arguments)).to eq(arguments)
    end
  end
end
