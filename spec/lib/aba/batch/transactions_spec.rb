# encoding: UTF-8

require "spec_helper"

describe Aba::Batch::Transactions do
  describe "#initialize" do
    it "initializes @collection" do
      expect(subject.instance_variable_get(:@collection)).to be_a(Array)
      expect(subject.instance_variable_get(:@collection)).to be_empty
    end
  end

  describe "#method_missing" do
    it "redirects any missing method to underlaying collection" do
      args = [:arg1, :arg2]
      block = Proc.new{ }

      expect(subject.instance_variable_get(:@collection))
        .to receive(:foo_bar)
        .with(args, &block)

      subject.foo_bar(args, &block)
    end
  end

  describe "#add_transaction" do
    let(:transaction) { Aba::Transaction.new(amount: 100) }

    it "adds given transaction to underlaying collection" do
      subject.add_transaction(transaction)

      expect(subject.instance_variable_get(:@collection))
        .to include(transaction)
    end
  end

  describe "#each" do
    context "when no block was given" do
      it "returns instance of Enumerator" do
        expect(subject.each).to be_an_instance_of(Enumerator)
      end
    end

    context "when block was given" do
      it "calls given block with each value from underlaying collection" do
        transaction_1 = Aba::Transaction.new(amount: 100)
        subject.add_transaction(transaction_1)

        transaction_2 = Aba::Transaction.new(amount: 200)
        subject.add_transaction(transaction_2)

        expect{ |block| subject.each(&block) }
          .to yield_successive_args(transaction_1, transaction_2)
      end
    end
  end

  describe "#valid?" do
    it "returns false" do
      expect(subject.valid?).to be_falsey
    end

    context "when some transactions were added" do
      let(:valid_transaction) do
        Aba::Transaction.new(
          amount: 100,
          transaction_code: 50,
          account_name: "John Doe",
          account_number: 23432342,
          bsb: "345-453",
          witholding_amount: 90,
          indicator: "W",
          lodgement_reference: "R45343",
          trace_bsb: "123-234",
          trace_account_number: "4647642",
          name_of_remitter: "Remitter"
        )
      end
      let(:invalid_transaction) { Aba::Transaction.new }

      context "when not all transactions are valid" do
        before do
          subject.add_transaction(valid_transaction)
          subject.add_transaction(invalid_transaction)
        end

        it "returns false" do
          expect(subject.valid?).to be_falsey
        end
      end

      context "when all transactions are valid" do
        before do
          subject.add_transaction(valid_transaction)
        end

        it "returns true" do
          expect(subject.valid?).to be_truthy
        end
      end
    end
  end

  describe "#validate!" do
    context "when no transaction was added" do
      before{ subject.instance_variable_set(:@collection, Array.new) }

      it "raises an exception" do
        expect{ subject.validate! }
          .to raise_error(Aba::Error, /no transactions/i)
      end
    end

    context "when some transactions were added" do
      context "when not all added transactions are valid" do
        before do
          subject.add_transaction(Aba::Transaction.new)
        end

        it "raises an exception" do
          expect{ subject.validate! }
            .to raise_error(Aba::Error, /transactions are invalid/)
        end
      end
    end
  end

  describe "#error_collection" do
    it "returns collection of transactions errors" do
      # Invalid transaction #1
      transaction_1 = Aba::Transaction.new
      allow(transaction_1)
        .to receive(:errors)
        .and_return(['error #1 for transaction #1', 'error #2 for transaction #1'])
      subject.add_transaction(transaction_1)

      # Invalid transaction #2
      transaction_2 = Aba::Transaction.new
      allow(transaction_2)
        .to receive(:errors)
        .and_return(['error #1 for transaction #2', 'error #2 for transaction #2'])
      subject.add_transaction(transaction_2)

      # Valid transaction #3
      transaction_3 = Aba::Transaction.new
      allow(transaction_3).to receive(:errors).and_return([])
      subject.add_transaction(transaction_3)

      errors = {
        0 => ['error #1 for transaction #1', 'error #2 for transaction #1'],
        1 => ['error #1 for transaction #2', 'error #2 for transaction #2']
      }

      expect(subject.error_collection).to eq(errors)
    end
  end

  describe "#to_s" do
    it "validates collection of transactions" do
      expect(subject).to receive(:validate!)

      subject.to_s
    end

    it "converts each transaction from collection of transactions to transactions records" do
      transaction_1 = Aba::Transaction.new
      subject.add_transaction(transaction_1)

      transaction_2 = Aba::Transaction.new
      subject.add_transaction(transaction_2)

      allow(subject).to receive(:validate!)

      expect(transaction_1).to receive(:to_s)
      expect(transaction_2).to receive(:to_s)

      subject.to_s
    end

    it "returns all transactions records joined together with carriage return and newline characters" do
      transaction_1 = Aba::Transaction.new
      allow(transaction_1).to receive(:to_s).and_return('transaction #1')
      subject.add_transaction(transaction_1)

      transaction_2 = Aba::Transaction.new
      allow(transaction_2).to receive(:to_s).and_return('transaction #2')
      subject.add_transaction(transaction_2)

      allow(subject).to receive(:validate!)

      expect(subject.to_s).to eq("transaction #1\r\ntransaction #2")
    end
  end
end
