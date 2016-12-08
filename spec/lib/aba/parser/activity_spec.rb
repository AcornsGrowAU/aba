# encoding: UTF-8

require "spec_helper"

describe Aba::Parser::Activity do
  it { is_expected.to be_a_kind_of(Aba::Parser::Line) }

  describe ".valid_record_types" do
    it "returns valid value for activity Record Type" do
      expect(described_class.valid_record_types).to eq(["1"])
    end
  end

  describe ".valid_line_length" do
    it "returns valid number of characters in activity line" do
      expect(described_class.valid_line_length).to eq(120)
    end
  end

  describe ".parse_line" do
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

      expect(described_class.parse_line(line)).to eq(parsed_line)
    end
  end

  describe ".prepare_record" do
    let(:arguments) { double('arguments') }

    it "initializes instance of Aba::Transaction with given arguments" do
      expect(Aba::Transaction).to receive(:new).with(arguments)

      described_class.prepare_record(arguments)
    end

    it "returns initialized instance of Aba::Transaction" do
      transaction = Aba::Transaction.new
      allow(Aba::Transaction)
        .to receive(:new)
        .with(arguments)
        .and_return(transaction)

      expect(described_class.prepare_record(arguments)).to eq(transaction)
    end
  end
end
