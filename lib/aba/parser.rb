require 'aba/parser/line'
require 'aba/parser/headers'
require 'aba/parser/activity'
require 'aba/parser/summary'

class Aba
  class Parser
    class Error < ::Exception; end

    def self.parse(input)
      if input.respond_to?(:gets)
        return parse_stream(input)
      elsif input.is_a?(String)
        return parse_text(input)
      else
        raise Aba::Parser::Error, "Could not parse given input!"
      end
    end

    def self.parse_line(line)
      line = line.gsub("\r", "").gsub("\n", "")

      if Aba::Parser::Headers.contains_valid_record_type?(line)
        return Aba::Batch.new(Aba::Parser::Headers.parse(line))
      elsif Aba::Parser::Activity.contains_valid_record_type?(line)
        return Aba::Transaction.new(Aba::Parser::Activity.parse(line))
      elsif Aba::Parser::Summary.contains_valid_record_type?(line)
        return Aba::Parser::Summary.parse(line)
      else
        raise Aba::Parser::Error, "Could not parse given input!"
      end
    end

    def self.parse_stream(stream)
      collection = Array.new
      batch = nil

      line = stream.gets
      until line.nil?
        result = parse_line(line)
        collection, batch = collect_results(collection, batch, result)
        line = stream.gets
      end

      return collection
    end

    def self.parse_text(text)
      collection = Array.new
      batch = nil

      text = text.split("\n")
      text.each do |line|
        result = parse_line(line)
        collection, batch = collect_results(collection, batch, result)
      end

      return collection
    end

    private

      def self.collect_results(collection, batch, result)
        if result.is_a?(Aba::Batch)
          collection, batch = handle_batch(collection, batch, result)
        elsif result.is_a?(Aba::Transaction)
          collection, batch = handle_transaction(collection, batch, result)
        elsif result.is_a?(Hash)
          collection, batch = handle_summary(collection, batch, result)
        end

        return [collection, batch]
      end

      def self.handle_batch(collection, batch, headers)
        if batch.nil?
          batch = headers

          return [collection, batch]
        else
          raise Aba::Parser::Error, "Previous batch wasn't finished when a new batch appeared"
        end
      end

      def self.handle_transaction(collection, batch, activity)
        unless batch.nil?
          batch.add_transaction(activity)

          return [collection, batch]
        else
          raise Aba::Parser::Error, "Transaction not within a batch"
        end
      end

      def self.handle_summary(collection, batch, summary)
        if batch.nil?
          raise Aba::Parser::Error, "Batch summary without a batch appeared"
        elsif summary_compatible_with_batch?(summary, batch)
          collection.push(batch)
          batch = nil

          return [collection, batch]
        else
          raise Aba::Parser::Error, "Summary line doesn't match calculated summary of current batch"
        end
      end

      def self.summary_compatible_with_batch?(summary, batch)
        result = (
          is_net_total_amount_correct?(summary, batch) &&
          is_credit_total_amount_correct?(summary, batch) &&
          is_debit_total_amount_correct?(summary, batch) &&
          is_count_of_transactions_correct?(summary, batch)
        )

        return result
      end

      def self.is_net_total_amount_correct?(summary, batch)
        summary[:net_total_amount] == batch.net_total_amount.abs
      end

      def self.is_credit_total_amount_correct?(summary, batch)
        summary[:credit_total_amount] == batch.credit_total_amount.abs
      end

      def self.is_debit_total_amount_correct?(summary, batch)
        summary[:debit_total_amount] == batch.debit_total_amount.abs
      end

      def self.is_count_of_transactions_correct?(summary, batch)
        summary[:count] == batch.count
      end
  end
end
