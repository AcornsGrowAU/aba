# encoding: UTF-8

require "spec_helper"

describe Aba::Parser do
  let(:filepath) do
    path = File.join(File.dirname(__FILE__), '../..', 'support/file.aba')
    File.absolute_path(path)
  end
  subject{ described_class.new(filepath) }

  describe ".initialize" do
    context "when file from given path doesn't exist" do
      it "raises an Aba::Parser::Error with proper message" do
        allow(File).to receive(:exists?).and_return(false)
        message = "File '/path/to/non-existent/file' doesn't exist!"

        expect{ described_class.new("/path/to/non-existent/file") }
          .to raise_error(Aba::Parser::Error, message)
      end
    end

    context "when file from given path exists" do
      it "sets filepath to @filepath" do
        expect(subject.filepath).to eq(filepath)
      end

      it "opens the file for reading" do
        expect(File).to receive(:open).with(filepath, "r")
        described_class.new(filepath)
      end

      it "sets opened file to @file" do
        file = instance_double(File)
        allow(File).to receive(:open).and_return(file)

        expect(subject.file).to eq(file)
      end
    end
  end

  describe "#parse" do
    context "when called for the first time" do
      it "calls #parse! to proceed" do
        allow(subject).to receive(:parse!)

        expect(subject).to receive(:parse!)
        subject.parse
      end
    end

    context "when callend for the Nth time" do
      it "returns memoized collections of batches" do
        collection = double
        subject.instance_variable_set(:@collection, collection)

        expect{ subject.parse }.not_to change{ subject.collection }
        expect(subject.parse).to eq(collection)
      end
    end
  end

  describe "#parse!" do
    context "when staring batch line occures" do
      let(:headers_line) { "0123-345          01WPC       John Doe                  466364Payroll     210915                                        " }

      before do
        allow(subject.file).to receive(:each_line).and_yield(headers_line)
      end

      it "parses the line" do
        allow(Aba::Batch).to receive(:new)

        expect(Aba::Parser::Headers).to receive(:parse).with(headers_line)
        subject.parse!
      end

      it "initializes new batch" do
        parsed_line = double
        allow(Aba::Parser::Headers).to receive(:parse).and_return(parsed_line)
        allow(Aba::Batch).to receive(:new)

        expect(Aba::Batch).to receive(:new).with(parsed_line)
        subject.parse!
      end

      it "sets new batch to @batch" do
        batch = double
        allow(Aba::Batch).to receive(:new).and_return(batch)

        expect{ subject.parse! }
          .to change{ subject.instance_variable_get(:@batch) }
          .to(batch)
      end
    end

    context "when transaction line occures" do
      let(:transaction_line) { "1342-342  3244654 530000010000John Doe                        R435564           453-543 45656733Remitter        00000010" }
      let(:batch) { instance_double(Aba::Batch).as_null_object }

      before do
        allow(subject.file).to receive(:each_line).and_yield(transaction_line)
        subject.instance_variable_set(:@batch, batch)
      end

      it "parses the line" do
        expect(Aba::Parser::Transaction).to receive(:parse).with(transaction_line)
        subject.parse!
      end

      it "adds new transaction to current batch" do
        parsed_line = double
        allow(Aba::Parser::Transaction).to receive(:parse).and_return(parsed_line)

        expect(batch).to receive(:add_transaction).with(parsed_line)
        subject.parse!
      end
    end

    context "when batch summary line occures" do
      let(:summary_line) { "7999-999            000010000000001000000000000000                        000010                                        " }

      before do
        allow(subject.file).to receive(:each_line).and_yield(summary_line)
      end

      it "parses the line" do
        allow(subject).to receive(:summary_compatible_with_batch?).and_return(true)

        expect(Aba::Parser::Summary).to receive(:parse).with(summary_line)
        subject.parse!
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

          expect{ subject.parse! }.to raise_error(Aba::Parser::Error, message)
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

          subject.parse!

          expect(subject.collection).to include(batch)
        end
      end
    end

    it "returns collections of batches" do
      allow(subject).to receive(:file).and_return(double.as_null_object)

      expect(subject.parse!).to be_a(Array)
    end
  end
end
