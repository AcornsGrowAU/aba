# encoding: UTF-8

require "spec_helper"

describe Aba do
  describe ".batch" do
    it "initializes instance of Aba::Batch with passed arguments" do
      attributes = double.as_null_object
      transactions = double.as_null_object

      expect(Aba::Batch).to receive(:new).with(attributes, transactions)
      described_class.batch(attributes, transactions)
    end

    it "returns instance of Aba::Batch" do
      obj = described_class.batch(double.as_null_object, double.as_null_object)

      expect(obj).to be_a(Aba::Batch)
    end
  end

  describe "#parse" do
    it "initializes instance of Aba::Parser with given path" do
      filepath = double
      allow(Aba::Parser).to receive(:new).and_return(double.as_null_object)

      expect(Aba::Parser).to receive(:new).with(filepath)
      described_class.parse(filepath)
    end

    it "parses given file" do
      filepath = double
      parser = double.as_null_object
      allow(Aba::Parser).to receive(:new).and_return(parser)

      expect(parser).to receive(:parse)
      described_class.parse(filepath)
    end
  end
end
