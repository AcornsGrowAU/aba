# encoding: UTF-8

require "spec_helper"

describe Aba::Parser::Line do
  describe ".record_type" do
    it "raises NoMethodError with proper message" do
      message = "This method should return correct 'Record Type' value and be implemented inside a class which inherites from this class!"

      expect{ described_class.record_type }
        .to raise_error(NoMethodError, message)
    end
  end

  describe ".contains_valid_record_type?" do
    let(:record_type) { "0" }

    before do
      allow(described_class).to receive(:record_type).and_return(record_type)
    end

    context "when given line doesn't have correct 'Record Type' value" do
      it "returns false" do
        expect(described_class.contains_valid_record_type?("Z")).to be_falsey
      end
    end

    context "when given line have correct 'Record Type' value" do
      it "returns true" do
        expect(described_class.contains_valid_record_type?(record_type)).to be_truthy
      end
    end
  end

  describe ".validate" do
    let(:record_type) { "0" }

    before do
      allow(described_class).to receive(:record_type).and_return(record_type)
    end

    context "when given line's 'Record Type' is not correct" do
      it "raises an Aba::Parser::Error with proper message" do
        line = "9"
        message = "Line's 'Record Type' should be '#{record_type}'"
        
        expect{ described_class.validate(line) }
          .to raise_error(Aba::Parser::Error, message)
      end
    end

    context "when given line length is not 120 characters" do
      it "raises an Aba::Parser::Error with proper message" do
        line = "#{record_type}123"
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

  describe ".record_type" do
    it "raises NoMethodError with proper message" do
      message = "This method should return result of parsing given line and be implemented inside a class which inherites from this class!"

      expect{ described_class.parse_line(instance_double(String)) }
        .to raise_error(NoMethodError, message)
    end
  end
end
