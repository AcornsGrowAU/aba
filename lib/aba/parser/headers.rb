class Aba
  class Parser
    class Headers < Line
      RECORD_TYPES = ["0"]
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
            bsb: line[1..17].strip,
            financial_institution: line[20..23].strip,
            user_name: line[30..55].strip,
            user_id: line[56..61].strip,
            description: line[62..73].strip,
            process_at: line[74..79].strip
          }

          return result
        end

        def self.prepare_record(parsed_line)
          return Aba::Batch.new(parsed_line)
        end
    end
  end
end
