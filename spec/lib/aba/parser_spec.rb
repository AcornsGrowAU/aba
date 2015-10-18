# encoding: UTF-8

require "spec_helper"

describe Aba::Parser do
  let(:input) { double }
  subject{ described_class.new(input) }

  describe ".initialize" do
    it "sets given input to @input" do
      expect(subject.instance_variable_get(:@input)).to eq(input)
    end

    it "sets @collection to empty array" do
      expect(subject.instance_variable_get(:@collection)).to be_empty
    end
  end

  describe "#parse" do
    context "when @input is a stream which responds to .gets" do
      it "reads input till returns nil" do
        allow(input).to receive(:respond_to?).with(:gets).and_return(true)
        allow(input).to receive(:gets).and_return(double, nil)
        allow(subject).to receive(:parse_line)

        expect(input).to receive(:gets).twice
        subject.parse
      end

      it "parses each line received from input" do
        allow(input).to receive(:respond_to?).with(:gets).and_return(true)
        line = double
        allow(input).to receive(:gets).and_return(line, line, nil)
        allow(subject).to receive(:parse_line)

        expect(subject).to receive(:parse_line).with(line).twice
        subject.parse
      end
    end

    context "when @input is a String" do
      it "splits @input per lines" do
        allow(input).to receive(:is_a?).with(String).and_return(true)
        allow(input).to receive(:split).with("\n").and_return(double.as_null_object)
        allow(subject).to receive(:parse_line)

        expect(input).to receive(:split).with("\n")
        subject.parse
      end

      it "parses each line" do
        allow(input).to receive(:is_a?).with(String).and_return(true)
        line = double
        allow(input).to receive(:split).with("\n").and_return([line, line])
        allow(subject).to receive(:parse_line)

        expect(subject).to receive(:parse_line).with(line).twice
        subject.parse
      end
    end

    context "when @input cannot be parsed" do
      it "raises an Aba::Parser::Error with proper message" do
        allow(input).to receive(:respond_to?).with(:gets).and_return(false)
        allow(input).to receive(:is_a?).with(String).and_return(false)
        message = "Could not parse given input!"

        expect{ subject.parse }
          .to raise_error(Aba::Parser::Error, message)
      end
    end
  end

  describe "#parse_line" do
    it "removes \\r from given line" do
      line = "0123-345          01WPC       John Doe                  466364Payroll     210915                                        "
      allow(line).to receive(:gsub).and_return(line)

      expect(line).to receive(:gsub).with("\r", "")
      subject.parse_line(line)
    end

    it "removes \\n from given line" do
      line = "0123-345          01WPC       John Doe                  466364Payroll     210915                                        "
      allow(line).to receive(:gsub).and_return(line)

      expect(line).to receive(:gsub).with("\n", "")
      subject.parse_line(line)
    end

    context "when starting batch line is given" do
      let(:headers_line) { "0123-345          01WPC       John Doe                  466364Payroll     210915                                        " }

      before do
        allow(headers_line).to receive(:gsub).and_return(headers_line)
      end

      it "parses the line" do
        allow(Aba::Batch).to receive(:new)

        expect(Aba::Parser::Headers).to receive(:parse).with(headers_line)
        subject.parse_line(headers_line)
      end

      it "initializes new batch" do
        parsed_line = double
        allow(Aba::Parser::Headers).to receive(:parse).and_return(parsed_line)
        allow(Aba::Batch).to receive(:new)

        expect(Aba::Batch).to receive(:new).with(parsed_line)
        subject.parse_line(headers_line)
      end

      it "sets new batch to @batch" do
        batch = double
        allow(Aba::Batch).to receive(:new).and_return(batch)

        expect{ subject.parse_line(headers_line) }
          .to change{ subject.instance_variable_get(:@batch) }
          .to(batch)
      end
    end

    context "when transaction line is given" do
      let(:transaction_line) { "1342-342  3244654 530000010000John Doe                        R435564           453-543 45656733Remitter        00000010" }
      let(:batch) { instance_double(Aba::Batch).as_null_object }

      before do
        allow(transaction_line).to receive(:gsub).and_return(transaction_line)
        subject.instance_variable_set(:@batch, batch)
      end

      it "parses the line" do
        expect(Aba::Parser::Activity).to receive(:parse).with(transaction_line)
        subject.parse_line(transaction_line)
      end

      it "adds new transaction to current batch" do
        parsed_line = double
        allow(Aba::Parser::Activity).to receive(:parse).and_return(parsed_line)

        expect(batch).to receive(:add_transaction).with(parsed_line)
        subject.parse_line(transaction_line)
      end
    end

    context "when batch summary line occures" do
      let(:summary_line) { "7999-999            000010000000001000000000000000                        000010                                        " }

      before do
        allow(summary_line).to receive(:gsub).and_return(summary_line)
      end

      it "parses the line" do
        allow(subject).to receive(:summary_compatible_with_batch?).and_return(true)

        expect(Aba::Parser::Summary).to receive(:parse).with(summary_line)
        subject.parse_line(summary_line)
      end

      context "when summary doesn't match summary of created batch" do
        it "raises an Aba::Parser::Error with proper message" do
          batch = instance_double(
            Aba::Batch,
            net_total_amount: 99999,
            credit_total_amount: 99999,
            debit_total_amount: 9,
            count: 99
          )
          subject.instance_variable_set(:@batch, batch)
          message = "Summary line for current batch from given doesn't batch calculated summary of that batch!"

          expect{ subject.parse_line(summary_line) }
            .to raise_error(Aba::Parser::Error, message)
        end
      end

      context "when summary line matches summary of created batch" do
        it "adds batch to collection" do
          batch = instance_double(
            Aba::Batch,
            net_total_amount: 100000,
            credit_total_amount: 100000,
            debit_total_amount: 0,
            count: 10
          )
          subject.instance_variable_set(:@batch, batch)

          subject.parse_line(summary_line)

          expect(subject.collection).to include(batch)
        end
      end
    end
  end
end
