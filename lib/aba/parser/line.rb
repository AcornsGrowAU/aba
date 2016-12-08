class Aba
  class Parser
    class Line
      def self.contains_valid_record_type?(line)
        return self.valid_record_types.any?{ |type| type == line[0..type.length-1] }
      end

      def self.parse(line)
        self.validate!(line)
        parsed_line = self.parse_line(line)
        result = self.prepare_record(parsed_line)

        return result
      end

      protected

        def self.validate!(line)
          self.validate_record_type!(line)
          self.validate_line_length!(line)
        end

        def self.validate_record_type!(line)
          unless self.contains_valid_record_type?(line)
            raise Aba::Parser::Error, "Line's 'Record Type' should be one of: '#{self.record_types.join(", ")}'"
          end
        end

        def self.validate_line_length!(line)
          if line.length != self.valid_line_length
            raise Aba::Parser::Error, "Line has #{line.length} characters but should have exactly #{self.valid_line_length} characters"
          end
        end

        def self.valid_record_types
          raise NoMethodError, "#{self.name}::#{__method__} method should return expected values of 'Record Type'!"
        end

        def self.valid_line_length
          raise NoMethodError, "#{self.name}::#{__method__} method should return expected number of characters in given line!"
        end

        def self.parse_line(_line)
          raise NoMethodError, "#{self.name}::#{__method__} method should implement expected way of parsing given line!"
        end

        def self.prepare_record(_parsed_line)
          raise NoMethodError, "#{self.name}::#{__method__} method should implement expected way of preparing record from parsed line!"
        end
    end
  end
end
