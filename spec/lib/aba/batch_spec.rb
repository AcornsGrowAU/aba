# encoding: UTF-8

require "spec_helper"

describe Aba::Batch do
  subject do
    Aba::Batch.new(
      financial_institution: "WPC",
      user_name: "John Doe",
      user_id: "466364",
      description: "Payroll",
      process_at: "190615"
    )
  end

  describe ".initialize" do
    it "initializes @transactions" do
      expect(subject.transactions).to be_a(Array)
      expect(subject.transactions).to be_empty
    end
  end

  describe "#to_s" do
    let(:transaction_values) { [30, -20] }
    let(:transactions) do
      transaction_values.map do |amount|
        Aba::Transaction.new(bsb: '342-342', account_number: '3244654', amount: amount,
        account_name: 'John Doe', transaction_code: 53,
        lodgement_reference: 'R435564', trace_bsb: '453-543',
        trace_account_number: '45656733', name_of_remitter: 'Remitter')
      end
    end
    before { transactions.each { |trx| subject.add_transaction(trx) } }

    context 'when descriptive record' do

      context 'without bsb' do
        it "should return a string containing the descriptive record without the bsb" do
          expect(subject.to_s).to include("0                 01WPC       John Doe                  466364Payroll     190615                                        \r\n")
        end
      end

      context 'with bsb' do
        before { subject.bsb = "123-345" }
        it "should return a string containing the descriptive record with the bsb" do
          expect(subject.to_s).to include("0123-345          01WPC       John Doe                  466364Payroll     190615                                        \r\n")
        end
      end
    end


    context 'when detail record' do

      it "should contain transactions records" do
        expect(subject.to_s).to include("1342-342  3244654 530000000030John Doe                        R435564           453-543 45656733Remitter        00000000\r\n")
        expect(subject.to_s).to include("1342-342  3244654 530000000020John Doe                        R435564           453-543 45656733Remitter        00000000\r\n")
      end
    end

    context 'when file total record' do

      context 'with unbalanced transactions' do
        it "should return a string wihere the net total is not zero" do
          expect(subject.to_s).to include("7999-999            000000001000000000300000000020                        000002                                        ")
        end
      end

      context 'with balanced transactions' do
        let(:transaction_values) { [30, 30, -60] }
        it "should return a string where the net total is zero" do
          expect(subject.to_s).to include("7999-999            000000000000000000600000000060                        000003                                        ")
        end
      end
    end
  end

  describe "#add_transaction" do
    it "adds new transaction to @transactions" do
      transaction = instance_double(Aba::Transaction, :'instance_of?' => true)

      subject.add_transaction(transaction)

      expect(subject.transactions).to include(transaction)
    end
  end

  describe ".transactions_valid?" do
    context "when one or more transactions are not valid" do
      it "returns false" do
        transaction_1 = instance_double(
          Aba::Transaction,
          :'instance_of?' => true,
          :'valid?' => true
        )
        transaction_2 = instance_double(
          Aba::Transaction,
          :'instance_of?' => true,
          :'valid?' => false
        )
        subject.add_transaction(transaction_1)
        subject.add_transaction(transaction_2)


        expect(subject.transactions_valid?).to be_falsey
      end
    end

    context "when every single transaction is valid" do
      it "returns true" do
        transaction_1 = instance_double(
          Aba::Transaction,
          :'instance_of?' => true,
          :'valid?' => true
        )
        transaction_2 = instance_double(
          Aba::Transaction,
          :'instance_of?' => true,
          :'valid?' => true
        )
        subject.add_transaction(transaction_1)
        subject.add_transaction(transaction_2)


        expect(subject.transactions_valid?).to be_truthy
      end
    end
  end
end
