# encoding: UTF-8

require "spec_helper"

describe Aba::Parser::Line do
  subject{ described_class }

  describe ".contains_valid_record_type?" do
    let(:invalid_record_type) { "invalid_record_type" }
    let(:valid_record_type) { "valid_record_type" }
    let(:valid_record_types) { [valid_record_type] }

    before do
      allow(subject)
        .to receive(:valid_record_types)
        .and_return(valid_record_types)
    end

    context "when given line doesn't have correct 'Record Type' value" do
      it "returns false" do
        result = subject.contains_valid_record_type?(invalid_record_type)

        expect(result).to be_falsey
      end
    end

    context "when given line has correct 'Record Type' value" do
      it "returns true" do
        result = subject.contains_valid_record_type?(valid_record_type)

        expect(result).to be_truthy
      end
    end
  end

  describe ".parse" do
    let(:line) { double('line') }

    it "validates given line" do
      allow(subject).to receive(:parse_line).and_return(double)
      allow(subject).to receive(:prepare_record).and_return(double)

      expect(subject).to receive(:validate!).with(line)

      subject.parse(line)
    end

    it "parses given line" do
      allow(subject).to receive(:validate!).and_return(double)
      allow(subject).to receive(:prepare_record).and_return(double)

      expect(subject).to receive(:parse_line).with(line)

      subject.parse(line)
    end

    it "prepares record from result of parsing given line" do
      allow(subject).to receive(:validate!).and_return(double)
      parsed_line = double('parsed line')
      allow(subject).to receive(:parse_line).and_return(parsed_line)

      expect(subject)
        .to receive(:prepare_record)
        .with(parsed_line)
        .and_return(double)

      subject.parse(line)
    end

    it "returns prepared record" do
      allow(subject).to receive(:validate!).and_return(double)
      allow(subject).to receive(:parse_line).and_return(double)
      prepared_record = double('prepared record')
      allow(subject).to receive(:prepare_record).and_return(prepared_record)

      expect(subject.parse(line)).to eq(prepared_record)

      subject.parse(line)
    end
  end

  describe ".validate!" do
    let(:line) { double('line') }

    it "validates 'Record Type' of given line" do
      allow(subject).to receive(:validate_line_length!)

      expect(subject).to receive(:validate_record_type!).with(line)

      subject.validate!(line)
    end

    it "validates lenght of given line" do
      allow(subject).to receive(:validate_record_type!)

      expect(subject).to receive(:validate_line_length!).with(line)

      subject.validate!(line)
    end
  end

  describe ".validate_record_type!" do
    context "when given line doesn't contain correct 'Record Type'" do
      before do
        allow(subject).to receive(:contains_valid_record_type?).and_return(false)
      end

      it "raises Aba::Parser::Error" do
        allow(subject)
          .to receive(:record_types)
          .and_return(double.as_null_object)
        message = /Line's 'Record Type' should be one of/

        expect{ subject.validate_record_type!(double) }
          .to raise_error(Aba::Parser::Error, message)
      end
    end

    context "when given line contains correct 'Record Type'" do
      before do
        allow(subject).to receive(:contains_valid_record_type?).and_return(true)
      end

      it "does not raise Aba::Parser::Error" do
        expect{ subject.validate_record_type!(double) }.not_to raise_error
      end
    end
  end

  describe ".validate_line_length!" do
    context "when lenght of given line is not exactly expected number" do
      let(:line) { double('line', length: 10) }
      before{ allow(subject).to receive(:valid_line_length).and_return(100) }

      it "raises Aba::Parser::Error" do
        expect{ subject.validate_line_length!(line) }
          .to raise_error(Aba::Parser::Error, /should have exactly 100 characters/)
      end
    end

    context "when lenght of given line is exactly expected number" do
      let(:line) { double('line', length: 100) }
      before{ allow(subject).to receive(:valid_line_length).and_return(100) }

      it "does not raise Aba::Parser::Error" do
        expect{ subject.validate_line_length!(line) }.not_to raise_error
      end
    end
  end

  describe ".valid_record_types" do
    it "raises NoMethodError" do
      message = /method should return expected values of 'Record Type'/

      expect{ subject.valid_record_types }.to raise_error(NoMethodError, message)
    end
  end

  describe ".valid_line_length" do
    it "raises NoMethodError" do
      message = /method should return expected number of characters in given line/

      expect{ subject.valid_line_length }.to raise_error(NoMethodError, message)
    end
  end

  describe ".parse_line" do
    it "raises NoMethodError" do
      message = /method should implement expected way of parsing given line/

      expect{ subject.parse_line(double) }.to raise_error(NoMethodError, message)
    end
  end

  describe ".prepare_record" do
    it "raises NoMethodError" do
      message = /method should implement expected way of preparing record from parsed line/

      expect{ subject.prepare_record(double) }
        .to raise_error(NoMethodError, message)
    end
  end
end
