# encoding: UTF-8

require "spec_helper"

describe Aba::Parser do
  subject{ described_class }
  let(:batch_line) { "0123-345          01WPC       John Doe                  466364Payroll     210915                                        " }
  let(:transaction_line) { "1342-342  3244654 500000010000John Doe                        R435564           453-543 45656733Remitter        00000010" }
  let(:summary_line) { "7999-999            000001000000000100000000000000                        000001                                        " }


  describe ".parse" do
    let(:input) { double('input') }

    context "when given input is a stream" do
      before do
        allow(input).to receive(:gets).and_return(true)
      end

      it "calls .parse_stream with given input" do
        expect(subject).to receive(:parse_stream).with(input)

        subject.parse(input)
      end

      it "returns result of .parse_stream" do
        result = double('result')
        allow(subject).to receive(:parse_stream).and_return(result)

        expect(subject.parse(input)).to eq(result)
      end
    end

    context "when given input is a block of text" do
      before do
        allow(input).to receive(:is_a?).with(String).and_return(true)
      end

      it "calls .parse_text with given input" do
        expect(subject).to receive(:parse_text).with(input)

        subject.parse(input)
      end

      it "returns result of .parse_text" do
        result = double('result')
        allow(subject).to receive(:parse_text).and_return(result)

        expect(subject.parse(input)).to eq(result)
      end
    end

    context "when given input cannot be parsed" do
      it "raises exception with proper message" do
        expect{ subject.parse(1) }
          .to raise_error(Aba::Parser::Error, "Could not parse given input!")
      end
    end
  end

  describe ".parse_line" do
    it "removes \\r from given line" do
      allow(batch_line).to receive(:gsub).and_return(batch_line)

      expect(batch_line).to receive(:gsub).with("\r", "")

      subject.parse_line(batch_line)
    end

    it "removes \\n from given line" do
      allow(batch_line).to receive(:gsub).and_return(batch_line)

      expect(batch_line).to receive(:gsub).with("\n", "")

      subject.parse_line(batch_line)
    end

    context "when a starting batch line is given" do
      it "parses batch line" do
        expect(Aba::Parser::Headers).to receive(:parse).with(batch_line)

        subject.parse_line(batch_line)
      end
    end

    context "when a transaction line is given" do
      it "parses transaction line" do
        expect(Aba::Parser::Activity).to receive(:parse).with(transaction_line)

        subject.parse_line(transaction_line)
      end
    end

    context "when batch summary line is given" do
      it "parses summary line" do
        expect(Aba::Parser::Summary).to receive(:parse).with(summary_line)

        subject.parse_line(summary_line)
      end
    end

    context "when given input cannot be parsed" do
      it "raises exception with proper message" do
        expect{ subject.parse(1) }
          .to raise_error(Aba::Parser::Error, "Could not parse given input!")
      end
    end
  end

  describe ".parse_stream" do
    let(:input) { double('stream') }

    context "when given input contains incorrect data" do
      context "when two different batches occur" do
        it "raises exception with proper message" do
          allow(input).to receive(:gets).and_return(batch_line, batch_line, nil)
          message = "Previous batch wasn't finished when a new batch appeared"

          expect{ subject.parse_stream(input) }
            .to raise_error(Aba::Parser::Error, message)
        end
      end

      context "when transaction without a batch occures" do
        it "raises exception with proper message" do
          allow(input).to receive(:gets).and_return(transaction_line, nil)
          message = "Transaction not within a batch"

          expect{ subject.parse_stream(input) }
            .to raise_error(Aba::Parser::Error, message)
        end
      end

      context "when summary without a batch occures" do
        it "raises exception with proper message" do
          allow(input).to receive(:gets).and_return(summary_line, nil)
          message = "Batch summary without a batch appeared"

          expect{ subject.parse_stream(input) }
            .to raise_error(Aba::Parser::Error, message)
        end
      end

      context "when summary doesn't match batch" do
        it "raises exception with proper message" do
          # To simulate invalid summary, we add 2 transactions while summary
          # line contains only data for one transaction.
          allow(input)
            .to receive(:gets)
            .and_return(batch_line, transaction_line, transaction_line, summary_line, nil)
          message = "Summary line doesn't match calculated summary of current batch"

          expect{ subject.parse_stream(input) }
            .to raise_error(Aba::Parser::Error, message)
        end
      end
    end

    it "skips empty lines" do
      allow(input)
        .to receive(:gets)
        .and_return(batch_line, "", transaction_line, "", summary_line, "", nil)

      expect(subject).to receive(:parse_line).with("").exactly(0).times

      subject.parse_stream(input)
    end

    it "returns parsed collection" do
      batch = Aba::Batch.new(
        bsb: "123-345",
        financial_institution: "WPC",
        user_name: "John Doe",
        user_id: "466364",
        description: "Payroll",
        process_at: "210915"
      )
      transaction = Aba::Transaction.new(
        bsb: "342-342",
        account_number: "3244654",
        indicator: " ",
        transaction_code: 50,
        amount: 10000,
        account_name: "John Doe",
        lodgement_reference: "R435564",
        trace_bsb: "453-543",
        trace_account_number: "45656733",
        name_of_remitter: "Remitter",
        witholding_amount: 10
      )
      batch.add_transaction(transaction)

      allow(input)
        .to receive(:gets)
        .and_return(batch_line, transaction_line, summary_line, nil)

      result = subject.parse_stream(input)
      parsed_batch = result.first
      parsed_transaction = parsed_batch.transactions.first

      expect(parsed_batch.to_s).to eq(batch.to_s)
    end
  end

  describe ".parse_text" do
    context "when given input contains incorrect data" do
      context "when two different batches occur" do
        it "raises exception with proper message" do
          text = [batch_line, batch_line].join("\n")
          message = "Previous batch wasn't finished when a new batch appeared"

          expect{ subject.parse_text(text) }
            .to raise_error(Aba::Parser::Error, message)
        end
      end

      context "when transaction without a batch occures" do
        it "raises exception with proper message" do
          message = "Transaction not within a batch"

          expect{ subject.parse_text(transaction_line) }
            .to raise_error(Aba::Parser::Error, message)
        end
      end

      context "when summary without a batch occures" do
        it "raises exception with proper message" do
          message = "Batch summary without a batch appeared"

          expect{ subject.parse_text(summary_line) }
            .to raise_error(Aba::Parser::Error, message)
        end
      end

      context "when summary doesn't match batch" do
        it "raises exception with proper message" do
          # To simulate invalid summary, we add 2 transactions while summary
          # line contains only data for one transaction.
          text = [batch_line, transaction_line, transaction_line, summary_line].join("\n")
          message = "Summary line doesn't match calculated summary of current batch"

          expect{ subject.parse_text(text) }
            .to raise_error(Aba::Parser::Error, message)
        end
      end
    end

    it "skips empty lines" do
      text = [batch_line, "", transaction_line, "", summary_line, ""].join("\n")

      expect(subject).to receive(:parse_line).with("").exactly(0).times

      subject.parse_text(text)
    end

    it "returns parsed collection" do
      batch = Aba::Batch.new(
        bsb: "123-345",
        financial_institution: "WPC",
        user_name: "John Doe",
        user_id: "466364",
        description: "Payroll",
        process_at: "210915"
      )
      transaction = Aba::Transaction.new(
        bsb: "342-342",
        account_number: "3244654",
        indicator: " ",
        transaction_code: 50,
        amount: 10000,
        account_name: "John Doe",
        lodgement_reference: "R435564",
        trace_bsb: "453-543",
        trace_account_number: "45656733",
        name_of_remitter: "Remitter",
        witholding_amount: 10
      )
      batch.add_transaction(transaction)
      text = [batch_line, transaction_line, summary_line].join("\n")

      result = subject.parse_text(text)
      parsed_batch = result.first
      parsed_transaction = parsed_batch.transactions.first

      expect(parsed_batch.to_s).to eq(batch.to_s)
    end
  end
end
