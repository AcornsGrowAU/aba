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

    context "transactions" do
      it "initializes collection of transactions" do
        expect(described_class::Transactions).to receive(:new)

        subject
      end

      it "memoizes initialized collection of transactions" do
        transactions = described_class::Transactions.new
        allow(described_class::Transactions)
          .to receive(:new)
          .and_return(transactions)

        expect(subject.transactions).to eq(transactions)
      end
    end

    context "summary" do
      it "initializes instance of summary" do
        expect(described_class::Summary).to receive(:new)

        subject
      end

      it "memoizes initialized instance of summary" do
        summary = described_class::Summary.new
        allow(described_class::Summary).to receive(:new).and_return(summary)

        expect(subject.summary).to eq(summary)
      end
    end
  end

  describe "#count" do
    it "is delegated to transactions" do
      expect(subject.transactions).to receive(:count)

      subject.count
    end
  end

  describe "#net_total_amount" do
    it "is delegated to summary" do
      expect(subject.summary).to receive(:net_total_amount)

      subject.net_total_amount
    end
  end

  describe "#credit_total_amount" do
    it "is delegated to summary" do
      expect(subject.summary).to receive(:credit_total_amount)

      subject.credit_total_amount
    end
  end

  describe "#debit_total_amount" do
    it "is delegated to summary" do
      expect(subject.summary).to receive(:debit_total_amount)

      subject.debit_total_amount
    end
  end

  describe "#add_transaction" do
    context "when given argument is an instance of Aba::Transaction" do
      let(:argument) { Aba::Transaction.new(amount: 100) }

      it "adds given argument to collection of transactions" do
        expect(subject.transactions).to receive(:add_transaction).with(argument)

        subject.add_transaction(argument)
      end

      it "adds given argument to summary" do
        expect(subject.summary).to receive(:add_transaction).with(argument)

        subject.add_transaction(argument)
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

        expect(subject.transactions)
          .to receive(:add_transaction)
          .with(transaction)

        subject.add_transaction(argument)
      end

      it "adds created instance of Aba::Transaction to summary" do
        allow(Aba::Transaction).to receive(:new).and_return(transaction)

        expect(subject.summary).to receive(:add_transaction).with(transaction)

        subject.add_transaction(argument)
      end
    end
  end

  describe "#valid?" do
    it "returns false" do
      expect(subject.valid?).to be_falsey
    end

    context "when headers are valid" do
      before do
        allow(subject.headers).to receive(:valid?).and_return(true)
      end

      it "returns false" do
        expect(subject.valid?).to be_falsey
      end

      context "when transactions are valid" do
        before do
          allow(subject.transactions).to receive(:valid?).and_return(true)
        end

        it "returns true" do
          expect(subject.valid?).to be_truthy
        end
      end
    end
  end

  describe "#error_collection" do
    it "validates headers" do
      allow(subject.headers)
        .to receive(:errors)
        .and_return(double.as_null_object)

      expect(subject.headers).to receive(:valid?)

      subject.error_collection
    end

    it "validates transactions" do
      allow(subject.transactions)
        .to receive(:errors)
        .and_return(double.as_null_object)

      expect(subject.transactions).to receive(:valid?)

      subject.error_collection
    end
  end

  describe "#to_s" do
    it "converts headers into descriptive record" do
      allow(subject.transactions).to receive(:to_s).and_return("transactions")
      allow(subject.summary).to receive(:to_s).and_return("summary")

      expect(subject.headers).to receive(:to_s).and_return("headers")

      subject.to_s
    end

    it "converts transactions to detail records" do
      allow(subject.headers).to receive(:to_s).and_return("headers")
      allow(subject.summary).to receive(:to_s).and_return("summary")

      expect(subject.transactions).to receive(:to_s).and_return("transactions")

      subject.to_s
    end

    it "converts summary into summary record" do
      allow(subject.headers).to receive(:to_s).and_return("headers")
      allow(subject.transactions).to receive(:to_s).and_return("transactions")

      expect(subject.summary).to receive(:to_s).and_return("summary")

      subject.to_s
    end

    it "returns all records joined together with carriage return and newline characters" do
      allow(subject.headers).to receive(:to_s).and_return("headers")
      allow(subject.transactions).to receive(:to_s).and_return("transactions")
      allow(subject.summary).to receive(:to_s).and_return("summary")

      expect(subject.to_s).to eq("headers\r\ntransactions\r\nsummary")
    end
  end
end
