class Aba
  class Parser
    class Summary < Line
      RECORD_TYPES = ["7"]
      LINE_LENGTH = 120

      protected

        def self.valid_record_types
          return RECORD_TYPES
        end

        def self.valid_line_length
          return LINE_LENGTH
        end

        def self.parse_line(line)
          result = {
            bsb: line[1..7].strip,
            net_total_amount: line[20..29].strip.to_i,
            credit_total_amount: line[30..39].strip.to_i,
            debit_total_amount: line[40..49].strip.to_i,
            count: line[74..79].strip.to_i
          }

          return result
        end

        def self.prepare_record(parsed_line)
          return parsed_line
        end
    end
  end
end
