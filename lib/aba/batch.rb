require "aba/batch/headers"

class Aba
  class Batch
    attr_reader :headers, :transactions, :credit_total_amount,
      :debit_total_amount

    def initialize(attrs = {}, transactions = [])
      @headers = self.class::Headers.new(attrs)
      @transactions = []
      @credit_total_amount = 0
      @debit_total_amount  = 0

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
      output += "\r\n#{batch_control_record}"

      return output
    end

    def add_transaction(attrs = {})
      if attrs.kind_of?(Aba::Transaction)
        transaction = attrs
      else
        transaction = Aba::Transaction.new(attrs)
      end

      @transactions.push(transaction)
      @credit_total_amount += transaction.amount.to_i if transaction.is_credit?
      @debit_total_amount += transaction.amount.to_i if transaction.is_debit?

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

    def net_total_amount
      return (@credit_total_amount + @debit_total_amount)
    end

    private

    def has_transaction_errors?
      return @transactions.map(&:valid?).include?(false)
    end

    def batch_control_record
      # Record type
      # Max: 1
      # Char position: 1
      output = "7"

      # BSB Format Filler
      # Max: 7
      # Char position: 2-8
      output += "999-999"

      # Reserved
      # Max: 12
      # Char position: 9-20
      output += " " * 12

      # Net total
      # Max: 10
      # Char position: 21-30
      output += net_total_amount.abs.to_s.rjust(10, "0")

      # Credit Total Amount
      # Max: 10
      # Char position: 31-40
      output += credit_total_amount.abs.to_s.rjust(10, "0")

      # Debit Total Amount
      # Max: 10
      # Char position: 41-50
      output += debit_total_amount.abs.to_s.rjust(10, "0")

      # Reserved
      # Max: 24
      # Char position: 51-74
      output += " " * 24

      # Total Item Count
      # Max: 6
      # Char position: 75-80
      output += count.to_s.rjust(6, "0")

      # Reserved
      # Max: 40
      # Char position: 81-120
      output += " " * 40

      return output
    end
  end
end
