require 'aba/parser/line'
require 'aba/parser/headers'
require 'aba/parser/activity'
require 'aba/parser/summary'

class Aba
  class Parser
    class Error < Aba::Error; end

    def self.parse(input)
      if input.respond_to?(:gets)
        return self.parse_stream(input)
      elsif input.is_a?(String)
        return self.parse_text(input)
      else
        raise self::Error, "Could not parse given input!"
      end
    end

    def self.parse_line(line)
      line = line.gsub("\r", "").gsub("\n", "")

      if self::Headers.contains_valid_record_type?(line)
        return self::Headers.parse(line)
      elsif self::Activity.contains_valid_record_type?(line)
        return self::Activity.parse(line)
      elsif self::Summary.contains_valid_record_type?(line)
        return self::Summary.parse(line)
      else
        raise self::Error, "Could not parse given input!"
      end
    end

    def self.parse_stream(stream)
      collection = Array.new
      batch = nil

      line = stream.gets
      until self.is_stream_finished?(line)
        if line.strip.empty?
          line = stream.gets
          next
        end
        collection, batch = self.handle_line(collection, batch, line)
        line = stream.gets
      end

      return collection
    end

    def self.parse_text(text)
      collection = Array.new
      batch = nil

      text = text.split("\n")
      text.each do |line|
        next if line.strip.empty?
        collection, batch = self.handle_line(collection, batch, line)
      end

      return collection
    end

    protected

      def self.is_stream_finished?(line)
        return line.nil?
      end

      def self.handle_line(collection, batch, line)
        result = self.parse_line(line)
        collection, batch = self.collect_results(collection, batch, result)

        return [collection, batch]
      end

      def self.collect_results(collection, batch, result)
        if result.is_a?(Aba::Batch)
          collection, batch = self.handle_batch(collection, batch, result)
        elsif result.is_a?(Aba::Transaction)
          collection, batch = self.handle_transaction(collection, batch, result)
        elsif result.is_a?(Hash)
          collection, batch = self.handle_summary(collection, batch, result)
        end

        return [collection, batch]
      end

      def self.handle_batch(collection, batch, headers)
        if batch.nil?
          batch = headers

          return [collection, batch]
        else
          raise self::Error, "Previous batch wasn't finished when a new batch appeared"
        end
      end

      def self.handle_transaction(collection, batch, activity)
        unless batch.nil?
          batch.add_transaction(activity)

          return [collection, batch]
        else
          raise self::Error, "Transaction not within a batch"
        end
      end

      def self.handle_summary(collection, batch, summary)
        if batch.nil?
          raise self::Error, "Batch summary without a batch appeared"
        elsif self.summary_compatible_with_batch?(summary, batch)
          collection.push(batch)
          batch = nil

          return [collection, batch]
        else
          raise self::Error, "Summary line doesn't match calculated summary of current batch"
        end
      end

      def self.summary_compatible_with_batch?(summary, batch)
        result = (
          self.is_net_total_amount_correct?(summary, batch) &&
          self.is_credit_total_amount_correct?(summary, batch) &&
          self.is_debit_total_amount_correct?(summary, batch) &&
          self.is_count_of_transactions_correct?(summary, batch)
        )

        return result
      end

      def self.is_net_total_amount_correct?(summary, batch)
        return (summary[:net_total_amount] == batch.net_total_amount.abs)
      end

      def self.is_credit_total_amount_correct?(summary, batch)
        return (summary[:credit_total_amount] == batch.credit_total_amount.abs)
      end

      def self.is_debit_total_amount_correct?(summary, batch)
        return (summary[:debit_total_amount] == batch.debit_total_amount.abs)
      end

      def self.is_count_of_transactions_correct?(summary, batch)
        return (summary[:count] == batch.count)
      end
  end
end
