require 'aba/parser/line'
require 'aba/parser/headers'
require 'aba/parser/activity'
require 'aba/parser/summary'

class Aba
  class Parser
    class Error < ::Exception; end

    attr_reader :input, :collection

    def initialize(input)
      @input = input
      @collection = Array.new
    end

    def parse
      if @input.respond_to?(:gets)
        parse_stream(@input)
      elsif @input.is_a?(String)
        parse_string(@input)
      else
        raise Aba::Parser::Error, "Could not parse given input!"
      end
    end

    def parse_line(line)
      line = line.gsub("\r", "").gsub("\n", "")

      if Aba::Parser::Headers.contains_valid_record_type?(line)
        @batch = Aba::Batch.new(Aba::Parser::Headers.parse(line))
      elsif Aba::Parser::Activity.contains_valid_record_type?(line)
        @batch.add_transaction(Aba::Parser::Activity.parse(line))
      elsif Aba::Parser::Summary.contains_valid_record_type?(line)
        summary = Aba::Parser::Summary.parse(line)
        if summary_compatible_with_batch?(summary, @batch)
          @collection.push(@batch)
        else
          raise Aba::Parser::Error, "Summary line for current batch from given doesn't batch calculated summary of that batch!"
        end
      else
        raise Aba::Parser::Error, "Could not parse given input!"
      end
    end

    private

      def parse_stream(stream)
        line = stream.gets
        until line.nil?
          parse_line(line)
          line = stream.gets
        end
      end

      def parse_string(string)
        string = string.split("\n")
        string.each{ |line| parse_line(line) }
      end

      def summary_compatible_with_batch?(summary, batch)
        summary[:net_total_amount] == batch.net_total_amount &&
          summary[:credit_total_amount] == batch.credit_total_amount &&
          summary[:debit_total_amount] == batch.debit_total_amount &&
          summary[:count] == batch.count
      end
  end
end
