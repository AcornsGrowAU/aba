require "aba/batch/headers"
require "aba/batch/transactions"
require "aba/batch/summary"

class Aba
  class Batch
    extend Forwardable

    attr_reader :headers, :transactions, :summary

    def_delegators :@transactions, :count
    def_delegators :@summary, :net_total_amount, :credit_total_amount,
      :debit_total_amount

    def initialize(attrs = {}, transactions = [])
      @headers = self.class::Headers.new(attrs)
      @transactions = self.class::Transactions.new
      @summary = self.class::Summary.new

      unless transactions.nil? || transactions.empty?
        transactions.to_a.each do |t|
          add_transaction(t) unless t.nil? || t.empty?
        end
      end

      yield self if block_given?
    end

    def add_transaction(attrs = {})
      transaction = prepare_transaction(attrs)
      @transactions.add_transaction(transaction)
      @summary.add_transaction(transaction)
    end

    def valid?
      return (@headers.valid? && @transactions.valid?)
    end

    def error_collection
      # Run validations
      @headers.valid?
      @transactions.valid?

      # Build errors
      all_errors = {}
      all_errors[:headers] = @headers.errors unless @headers.errors.empty?
      all_errors[:transactions] = @transactions.errors unless @transactions.errors.empty?

      return all_errors unless all_errors.empty?
    end
    alias_method :errors, :error_collection

    def to_s
      # Descriptive record
      output = "#{@headers.to_s}\r\n"

      # Transactions records
      output += "#{@transactions.to_s}\r\n"

      # Batch control record
      output += @summary.to_s

      return output
    end

    private

      def prepare_transaction(attrs)
        if attrs.kind_of?(Aba::Transaction)
          transaction = attrs
        else
          transaction = Aba::Transaction.new(attrs)
        end

        return transaction
      end
  end
end
