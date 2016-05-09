# encoding: UTF-8

require "spec_helper"

describe Aba::Batch do
  let(:attributes) do
    {
      financial_institution: "WPC",
      user_name: "John Doe",
      user_id: "466364",
      description: "Payroll",
      process_at: "190615"
    }
  end
  subject{ described_class.new(attributes) }

  describe "#initialize" do
    context "headers" do
      it "initializes instance of headers with given attributes" do
        expect(described_class::Headers)
          .to receive(:new)
          .with(attributes)

        subject
      end

      it "memoizes initialized instance of headers" do
        headers = described_class::Headers.new
        allow(described_class::Headers).to receive(:new).and_return(headers)

        expect(subject.headers).to eq(headers)
      end
    end

    it "initializes @transactions" do
      expect(subject.transactions).to be_a(Array)
      expect(subject.transactions).to be_empty
    end

    it "initializes @credit_total_amount" do
      expect(subject.credit_total_amount).to be_zero
    end
    it "initializes @debit_total_amount" do
      expect(subject.debit_total_amount).to be_zero
    end
  end

  describe "#to_s" do
    context "when no transactions were added" do
      it "raises an exception" do
        expect{ subject.to_s }.to raise_error(RuntimeError, /no transactions/i)
      end
    end

    context "when transactions were added" do
      let(:raw_transaction) do
        Aba::Transaction.new(
          bsb: '342-342',
          account_number: '3244654',
          account_name: 'John Doe',
          lodgement_reference: 'R435564',
          trace_bsb: '453-543',
          trace_account_number: '45656733',
          name_of_remitter: 'Remitter'
        )
      end

      before do
        # Credit transactions
        [40, 30].each do |amount|
          transaction = raw_transaction.clone
          transaction.transaction_code = 50
          transaction.amount = amount
          subject.add_transaction(transaction)
        end

        # Debit transactions
        [20, 10].each do |amount|
          transaction = raw_transaction.clone
          transaction.transaction_code = 13
          transaction.amount = amount
          subject.add_transaction(transaction)
        end
      end

      it "converts headers into descriptive record" do
        expect(subject.headers).to receive(:to_s)

        subject.to_s
      end

      context 'when detail record' do
        it "should contain transactions records" do
          expect(subject.to_s).to include("1342-342  3244654 500000000040John Doe                        R435564           453-543 45656733Remitter        00000000\r\n")
          expect(subject.to_s).to include("1342-342  3244654 500000000030John Doe                        R435564           453-543 45656733Remitter        00000000\r\n")
          expect(subject.to_s).to include("1342-342  3244654 130000000020John Doe                        R435564           453-543 45656733Remitter        00000000\r\n")
          expect(subject.to_s).to include("1342-342  3244654 130000000010John Doe                        R435564           453-543 45656733Remitter        00000000\r\n")
        end
      end

      context 'when file total record' do
        context 'with unbalanced transactions' do
          it "should return a string wihere the net total is not zero" do
            expect(subject.to_s).to include("7999-999            000000010000000000700000000030                        000004                                        ")
          end
        end
      end
    end
  end

  describe "#add_transaction" do
    context "when given argument is an instance of Aba::Transaction" do
      let(:argument) { Aba::Transaction.new(amount: 100) }

      it "adds given argument to collection of transactions" do
        subject.add_transaction(argument)

        expect(subject.transactions).to include(argument)
      end

      context "when credit transaction" do
        it "increases credit amount of all transactions" do
          transaction = Aba::Transaction.new(transaction_code: 50, amount: 100)

          expect{ subject.add_transaction(transaction) }
            .to change{ subject.credit_total_amount }
            .by(100)
        end
      end

      context "when debit transaction" do
        it "increases debit amount of all transactions" do
          transaction = Aba::Transaction.new(transaction_code: 13, amount: 200)

          expect{ subject.add_transaction(transaction) }
            .to change{ subject.debit_total_amount }
            .by(200)
        end
      end

      it "returns given argument" do
        result = subject.add_transaction(argument)

        expect(result).to eq(argument)
      end
    end

    context "when given argument is not an instance of Aba::Transaction" do
      let(:argument) { double('argument') }
      let(:transaction) { Aba::Transaction.new(amount: 100) }

      it "creates an instance of Aba::Transaction based on given argument" do
        expect(Aba::Transaction)
          .to receive(:new)
          .with(argument)
          .and_return(transaction)

        subject.add_transaction(argument)
      end

      it "adds created instance of Aba::Transaction to collection of transactions" do
        allow(Aba::Transaction).to receive(:new).and_return(transaction)

        subject.add_transaction(argument)

        expect(subject.transactions).to include(transaction)
      end

     it "returns created instance of Aba::Transaction" do
        allow(Aba::Transaction).to receive(:new).and_return(transaction)

        result = subject.add_transaction(argument)

        expect(result).to eq(transaction)
      end
    end
  end

  describe "#transactions_valid?" do
    context "when one or more transactions are not valid" do
      it "returns false" do
        transaction_1 = instance_double(
          Aba::Transaction,
          kind_of?: true,
          amount: 100,
          valid?: true
        ).as_null_object
        transaction_2 = instance_double(
          Aba::Transaction,
          kind_of?: true,
          amount: 456,
          valid?: false
        ).as_null_object
        subject.add_transaction(transaction_1)
        subject.add_transaction(transaction_2)

        expect(subject.transactions_valid?).to be_falsey
      end
    end

    context "when every single transaction is valid" do
      it "returns true" do
        transaction_1 = instance_double(
          Aba::Transaction,
          kind_of?: true,
          amount: 100,
          valid?: true
        ).as_null_object
        transaction_2 = instance_double(
          Aba::Transaction,
          kind_of?: true,
          amount: 456,
          valid?: true
        ).as_null_object
        subject.add_transaction(transaction_1)
        subject.add_transaction(transaction_2)

        expect(subject.transactions_valid?).to be_truthy
      end
    end
  end

  describe "#errors" do
    it "validates headers" do
      allow(subject.headers)
        .to receive(:errors)
        .and_return(double.as_null_object)

      expect(subject.headers).to receive(:valid?)

      subject.errors
    end
  end

  describe "#count" do
    it "returns number of stored transactions" do
      subject.instance_variable_set(:@transactions, Array.new(5))

      expect(subject.count).to eq(5)
    end
  end
end
