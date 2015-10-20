# encoding: UTF-8

require "spec_helper"

describe Aba::Parser::Activity do
  it { is_expected.to be_a_kind_of(Aba::Parser::Line) }

  it "defines RECORD_TYPES constant with Record Type values" do
    expect(described_class::RECORD_TYPES).to match(['1'])
  end

  describe ".record_types" do
    it "returns value defined in RECORD_TYPES constant" do
      expect(described_class.record_types).to eq(described_class::RECORD_TYPES)
    end
  end

  describe ".parse" do
    it "returns parsed given line" do
      line = "1342-342  3244654 530000012345John Doe                        R435564           453-543 45656733Remitter        00000010"
      parsed_line = {
        bsb: "342-342",
        account_number: "3244654",
        indicator: " ",
        transaction_code: 53,
        amount: 12345,
        account_name: "John Doe",
        lodgement_reference: "R435564",
        trace_bsb: "453-543",
        trace_account_number: "45656733",
        name_of_remitter: "Remitter",
        witholding_amount: 10
      }

      expect(described_class.parse(line)).to eq(parsed_line)
    end
  end
end
