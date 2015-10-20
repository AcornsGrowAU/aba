class Aba
  class Parser
    class Headers < Line
      RECORD_TYPES = ["0"]

      def self.record_types
        RECORD_TYPES
      end

      def self.parse_line(line)
        results = {
          bsb: line[1..17].strip,
          financial_institution: line[20..23].strip,
          user_name: line[30..55].strip,
          user_id: line[56..61].strip,
          description: line[62..73].strip,
          process_at: line[74..79].strip
        }

        return results
      end
    end
  end
end
