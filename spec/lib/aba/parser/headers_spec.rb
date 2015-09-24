# encoding: UTF-8

require "spec_helper"

describe Aba::Parser::Headers do
  it { is_expected.to be_a_kind_of(Aba::Parser::Line) }

  it "defines RECORD_TYPE constant with value '0'" do
    expect(described_class::RECORD_TYPE).to eq('0')
  end

  describe ".record_type" do
    it "returns value defined in RECORD_TYPE constant" do
      expect(described_class.record_type).to eq(described_class::RECORD_TYPE)
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
