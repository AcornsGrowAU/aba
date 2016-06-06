# encoding: UTF-8

require "spec_helper"

describe Aba::Parser::Headers do
  it { is_expected.to be_a_kind_of(Aba::Parser::Line) }

  describe ".valid_record_types" do
    it "returns valid value for headers Record Type" do
      expect(described_class.valid_record_types).to eq(["0"])
    end
  end

  describe ".valid_line_length" do
    it "returns valid number of characters in headers line" do
      expect(described_class.valid_line_length).to eq(120)
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

      expect(described_class.parse_line(line)).to eq(parsed_line)
    end
  end

  describe ".prepare_record" do
    let(:arguments) { double('arguments') }

    it "initializes instance of Aba::Batch with given arguments" do
      expect(Aba::Batch).to receive(:new).with(arguments)

      described_class.prepare_record(arguments)
    end

    it "returns initialized instance of Aba::Batch" do
      transaction = Aba::Batch.new
      allow(Aba::Batch)
        .to receive(:new)
        .with(arguments)
        .and_return(transaction)

      expect(described_class.prepare_record(arguments)).to eq(transaction)
    end
  end
end
