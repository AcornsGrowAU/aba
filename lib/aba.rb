require "aba/version"
require "aba/validations"
require "aba/batch"
require "aba/transaction"
require "aba/parser"

class Aba
  def self.batch(attrs = {}, transactions = [])
    Aba::Batch.new(attrs, transactions)
  end

  def self.parse(filepath)
    Aba::Parser.new(filepath).parse
  end
end
