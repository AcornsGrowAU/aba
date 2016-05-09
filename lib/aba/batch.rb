require "aba/batch/headers"
require "aba/batch/summary"

class Aba
  class Batch
    extend Forwardable

    attr_reader :headers, :transactions, :summary

    def_delegators :@summary, :net_total_amount, :credit_total_amount,
      :debit_total_amount

    def initialize(attrs = {}, transactions = [])
      @headers = self.class::Headers.new(attrs)
      @transactions = []
      @summary = self.class::Summary.new

      unless transactions.nil? || transactions.empty?
        transactions.to_a.each do |t|
          self.add_transaction(t) unless t.nil? || t.empty?
        end
      end

      yield self if block_given?
    end

    def to_s
      if @transactions.empty?
        raise RuntimeError, 'No transactions present - add one using `add_transaction`'
      end

      # Descriptive record
      output = "#{@headers.to_s}\r\n"

      # Transactions records
      output += @transactions.map(&:to_s).join("\r\n")

      # Batch control record
      output += "\r\n#{@summary.to_s}"

      return output
    end

    def add_transaction(attrs = {})
      if attrs.kind_of?(Aba::Transaction)
        transaction = attrs
      else
        transaction = Aba::Transaction.new(attrs)
      end

      @transactions.push(transaction)
      @summary.add_transaction(transaction)

      return transaction
    end

    def transactions_valid?
      return !has_transaction_errors?
    end

    def valid?
      return (!has_errors? && transactions_valid?)
    end

    def errors
      # Run validations
      @headers.valid?
      has_transaction_errors?

      # Build errors
      all_errors = {}
      all_errors[:headers] = @headers.errors unless @headers.errors.empty?
      transaction_error_collection = @transactions.each_with_index.map{ |(k, t), i| [k, t.error_collection] }.reject{ |e| e[1].nil? || e[1].empty? }.to_h
      all_errors[:transactions] = transaction_error_collection unless transaction_error_collection.empty?

      return all_errors unless all_errors.empty?
    end

    def count
      return @transactions.count
    end

    private

    def has_transaction_errors?
      return @transactions.map(&:valid?).include?(false)
    end
  end
end
