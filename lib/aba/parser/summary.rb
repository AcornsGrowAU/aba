class Aba
  class Parser
    class Summary < Line
      RECORD_TYPES = ["7"]

      def self.record_types
        RECORD_TYPES
      end

      def self.handle(line)
        return self.parse(line)
      end

      def self.parse_line(line)
        results = {
          bsb: line[1..7].strip,
          net_total_amount: line[20..29].strip.to_i,
          credit_total_amount: line[30..39].strip.to_i,
          debit_total_amount: line[40..49].strip.to_i,
          count: line[74..79].strip.to_i
        }

        return results
      end
    end
  end
end
