class Aba
  class Parser
    class Line
      def self.record_types
        raise NoMethodError, "This method should return correct 'Record Type' values and be implemented inside a class which inherites from this class!"
      end

      def self.contains_valid_record_type?(line)
        return self.record_types.include?(line[0])
      end

      def self.handle(line)
        raise NoMethodError, "This method should implement expected way to handle given line and be implemented inside a class which inherites from this class!"
      end

      def self.validate(line)
        self.validate_record_type(line)
        self.validate_length(line)
      end

      def self.parse(line)
        self.validate(line)
        result = self.parse_line(line)

        return result
      end

      def self.parse_line(line)
        raise NoMethodError, "This method should return result of parsing given line and be implemented inside a class which inherites from this class!"
      end

      private

        def self.validate_record_type(line)
          unless self.contains_valid_record_type?(line)
            raise Aba::Parser::Error, "Line's 'Record Type' should be one of: '#{self.record_types.join(", ")}'"
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
