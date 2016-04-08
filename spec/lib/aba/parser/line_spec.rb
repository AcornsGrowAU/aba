# encoding: UTF-8

require "spec_helper"

describe Aba::Parser::Line do
  describe ".record_types" do
    it "raises NoMethodError with proper message" do
      message = "This method should return correct 'Record Type' values and be implemented inside a class which inherites from this class!"

      expect{ described_class.record_types }
        .to raise_error(NoMethodError, message)
    end
  end

  describe ".contains_valid_record_type?" do
    let(:valid_record_type) { "0" }
    let(:valid_record_types) { [valid_record_type] }

    before do
      allow(described_class)
        .to receive(:record_types)
        .and_return(valid_record_types)
    end

    context "when given line doesn't have correct 'Record Type' value" do
      it "returns false" do
        expect(described_class.contains_valid_record_type?("Z")).to be_falsey
      end
    end

    context "when given line have correct 'Record Type' value" do
      it "returns true" do
        result = described_class.contains_valid_record_type?(valid_record_type)

        expect(result).to be_truthy
      end
    end
  end

  describe ".handle" do
    let(:line) { instance_double(String) }

    it "raises NoMethodError with proper message" do
      message = "This method should implement expected way to handle given line and be implemented inside a class which inherites from this class!"

      expect{ described_class.handle(line) }
        .to raise_error(NoMethodError, message)
    end
  end

  describe ".validate" do
    let(:valid_record_type) { "0" }
    let(:valid_record_types) { [valid_record_type] }

    before do
      allow(described_class)
        .to receive(:record_types)
        .and_return(valid_record_types)
    end

    context "when given line's 'Record Type' is not correct" do
      it "raises an Aba::Parser::Error with proper message" do
        line = "9"
        message = "Line's 'Record Type' should be one of: '#{valid_record_types.join(", ")}'"

        expect{ described_class.validate(line) }
          .to raise_error(Aba::Parser::Error, message)
      end
    end

    context "when given line length is not 120 characters" do
      it "raises an Aba::Parser::Error with proper message" do
        line = "#{valid_record_type}123"
        message = "Line should have exactly 120 characters"

        expect{ described_class.validate(line) }
          .to raise_error(Aba::Parser::Error, message)
      end
    end
  end

  describe ".parse" do
    let(:line) { instance_double(String) }

    before do
      allow(described_class).to receive(:validate).with(line)
      allow(described_class).to receive(:parse_line).with(line)
    end

    it "validates given line" do
      expect(described_class).to receive(:validate).with(line)
      described_class.parse(line)
    end

    it "parses given line" do
      expect(described_class).to receive(:parse_line).with(line)
      described_class.parse(line)
    end
  end
end
