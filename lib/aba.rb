require "aba/version"
require "aba/validations"
require "aba/batch"
require "aba/transaction"
require "aba/parser"

class Aba
  def self.batch(attrs = {}, transactions = [])
    return Aba::Batch.new(attrs, transactions)
  end

  def self.parse(input)
    return Aba::Parser.parse(input)
  end
end
