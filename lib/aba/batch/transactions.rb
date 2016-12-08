class Aba
  class Batch
    class Transactions
      include Enumerable

      def initialize
        @collection = Array.new
      end

      def method_missing(name, *args)
        @collection.send(name, *args)
      end

      def add_transaction(transaction)
        @collection.push(transaction)
      end

      def each
        return enum_for(:each) unless block_given?

        @collection.each { |item| yield item }
      end

      def valid?
        return (!empty? && !map(&:valid?).include?(false))
      end

      def validate!
        if @collection.empty?
          raise Aba::Error, 'No transactions present - add one using #add_transaction method'
        end

        unless valid?
          raise Aba::Error, 'Some transactions are invalid - check output of #errors method for more information'
        end
      end

      def error_collection
        errors = each_with_index.map{ |t, i| [i, t.errors] }
        errors = errors.reject{ |e| e[1].nil? || e[1].empty? }
        errors = Hash[errors]

        return errors
      end
      alias_method :errors, :error_collection

      def to_s
        validate!

        return map(&:to_s).join("\r\n")
      end
    end
  end
end
