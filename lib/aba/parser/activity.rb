class Aba
  class Parser
    class Activity < Line
      RECORD_TYPES = ["1"]
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
            account_number: line[8..16].strip,
            indicator: line[17],
            transaction_code: line[18..19].to_i,
            amount: line[20..29].strip.to_i,
            account_name: line[30..61].strip,
            lodgement_reference: line[62..79].strip,
            trace_bsb: line[80..86].strip,
            trace_account_number: line[87..95].strip,
            name_of_remitter: line[96..111].strip,
            witholding_amount: line[112..120].strip.to_i
          }

          return result
        end

        def self.prepare_record(parsed_line)
          return Aba::Transaction.new(parsed_line)
        end
    end
  end
end
