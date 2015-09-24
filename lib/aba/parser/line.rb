class Aba
  class Parser
    class Line
      def self.record_type
        raise NoMethodError, "This method should return correct 'Record Type' value and be implemented inside a class which inherites from this class!"
      end

      def self.contains_valid_record_type?(line)
        line[0] == self.record_type
      end

      def self.validate(line)
        self.validate_record_type(line)
        self.validate_length(line)
      end

      def self.parse(line)
        self.validate(line)
        self.parse_line(line)
      end

      def self.parse_line(line)
        raise NoMethodError, "This method should return result of parsing given line and be implemented inside a class which inherites from this class!"
      end

      private

        def self.validate_record_type(line)
          unless self.contains_valid_record_type?(line)
            raise Aba::Parser::Error, "Line's 'Record Type' should be '#{self.record_type}'"
          end
        end

        def self.validate_length(line)
          if line.length != 120
            raise Aba::Parser::Error, "Line should have exactly 120 characters"
          end
        end
    end
  end
end
