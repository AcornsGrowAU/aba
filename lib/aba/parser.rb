require 'aba/parser/line'
require 'aba/parser/headers'
require 'aba/parser/transaction'
require 'aba/parser/summary'

class Aba
  class Parser
    class Error < ::Exception; end

    attr_reader :filepath, :file, :collection

    def initialize(filepath)
      unless File.exists?(filepath)
        raise Aba::Parser::Error, "File '#{filepath}' doesn't exist!"
      end

      @filepath = filepath
      @file = File.open(@filepath, "r")
    end

    def parse
      collection || parse!
    end

    def parse!
      @collection = Array.new

      file.each_line do |line|
        line.gsub!("\r\n", "")
        if Aba::Parser::Headers.contains_valid_record_type?(line)
          @batch = Aba::Batch.new(Aba::Parser::Headers.parse(line))
        elsif Aba::Parser::Transaction.contains_valid_record_type?(line)
          @batch.add_transaction(Aba::Parser::Transaction.parse(line))
        elsif Aba::Parser::Summary.contains_valid_record_type?(line)
          summary = Aba::Parser::Summary.parse(line)
          if summary_compatible_with_batch?(summary, @batch)
            @collection.push(@batch)
          else
            raise Aba::Parser::Error, "Summary line for current batch from given doesn't batch calculated summary of that batch!"
          end
        end
      end

      @collection
    end

    private

      def summary_compatible_with_batch?(summary, batch)
        summary[:net_total_amount] == batch.net_total_amount &&
          summary[:credit_total_amount] == batch.credit_total_amount &&
          summary[:debit_total_amount] == batch.debit_total_amount &&
          summary[:count] == batch.count
      end
  end
end
=begin
aba = Aba.parse(file)
aba = Aba::Parser.new("file").parse
#aba.headers
#aba.summary
aba.each do |batch|
  batch.headers
  batch.each do |transaction|
  end
  batch.summary
end

aba = Aba.batchnew(asd: zxc)
aba = Aba::Batch(asd: zxc)
aba.add_transaction({ asd: zxc })
aba.to_s
=end
