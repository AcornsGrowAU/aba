class Aba
  class Parser
    class Activity < Line
      RECORD_TYPE = "1"

      def self.record_type
        RECORD_TYPE
      end

      def self.parse_line(line)
        results = {
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

        return results
      end
    end
  end
end
