class Aba
  class Batch
    class Summary
      attr_reader :credit_total_amount, :debit_total_amount, :transactions_counter

      def initialize
        @credit_total_amount = 0
        @debit_total_amount = 0
        @transactions_counter = 0
      end

      def add_transaction(transaction)
        if transaction.is_credit?
          increase_credit_total_amount(transaction.amount)
        end

        if transaction.is_debit?
          increase_debit_total_amount(transaction.amount)
        end

        increase_transactions_counter
      end

      def net_total_amount
        return (@credit_total_amount + @debit_total_amount)
      end

      def to_s
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
        output += (@credit_total_amount.abs + @debit_total_amount.abs).to_s.rjust(10, "0")

        # Credit Total Amount
        # Max: 10
        # Char position: 31-40
        output += @credit_total_amount.abs.to_s.rjust(10, "0")

        # Debit Total Amount
        # Max: 10
        # Char position: 41-50
        output += @debit_total_amount.abs.to_s.rjust(10, "0")

        # Reserved
        # Max: 24
        # Char position: 51-74
        output += " " * 24

        # Total Item Count
        # Max: 6
        # Char position: 75-80
        output += @transactions_counter.to_s.rjust(6, "0")

        # Reserved
        # Max: 40
        # Char position: 81-120
        output += " " * 40

        return output
      end

      private

        def increase_credit_total_amount(amount)
          @credit_total_amount += amount.to_i
        end

        def increase_debit_total_amount(amount)
          @debit_total_amount += amount.to_i
        end

        def increase_transactions_counter
          @transactions_counter += 1
        end
    end
  end
end
