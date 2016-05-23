# encoding: UTF-8

require "spec_helper"

describe Aba::Batch::Summary do
  let(:credit) { Aba::Transaction.new(transaction_code: 50, amount: 100) }
  let(:debit) { Aba::Transaction.new(transaction_code: 13, amount: 200) }

  describe "#initialize" do
    it "initializes @credit_total_amount" do
      expect(subject.credit_total_amount).to be_zero
    end

    it "initializes @debit_total_amount" do
      expect(subject.debit_total_amount).to be_zero
    end

    it "initializes @transactions_counter" do
      expect(subject.transactions_counter).to be_zero
    end
  end

  describe "#add_transaction" do
    context "when given transaction is a credit transaction" do
      it "increases credit amount of all transactions" do
        expect{ subject.add_transaction(credit) }
          .to change{ subject.credit_total_amount }
          .by(credit.amount)
      end
    end

    context "when given transaction is a debit transaction" do
      it "increases debit amount of all transactions" do
        expect{ subject.add_transaction(debit) }
          .to change{ subject.debit_total_amount }
          .by(debit.amount)
      end
    end

    it "increases number of transactions" do
      expect{ subject.add_transaction(Aba::Transaction.new) }
        .to change{ subject.transactions_counter }
        .by(1)
    end
  end

  describe "#net_total_amount" do
    context "when no transaction was added" do
      it "returns 0" do
        expect(subject.net_total_amount).to eq(0)
      end
    end

    context "when some transactions were added" do
      it "returns sum of collected credit and debit amounts" do
        subject.add_transaction(credit)
        subject.add_transaction(debit)

        amount = credit.amount.abs - debit.amount.abs

        expect(subject.net_total_amount).to eq(amount)
      end
    end
  end

  describe "#to_s" do
    it "returns summary record as a string" do
      subject.add_transaction(credit)
      subject.add_transaction(debit)

      expect(subject.to_s).to eq("7999-999            000000010000000001000000000200                        000002                                        ")
    end
  end
end
