[![Build Status](https://travis-ci.org/andrba/aba.svg?branch=master)](https://travis-ci.org/andrba/aba) [![Code Climate](https://codeclimate.com/github/andrba/aba/badges/gpa.svg)](https://codeclimate.com/github/andrba/aba)

# Aba

Generates ABA (Australian Banking Association) file format output.

## Installation

Add this line to your application's Gemfile:

    gem 'aba'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aba

## Usage

#### Working with a batch

```ruby
require 'aba'

# Initialise ABA batch
aba = Aba.batch(
  bsb: "123-345", # Optional (Not required by NAB)
  financial_institution: "WPC",
  user_name: "John Doe",
  user_id: "466364",
  description: "Payroll",
  process_at: Time.now.strftime("%d%m%y")
)

# Add transactions
10.times do
  aba.add_transaction(
    {
      bsb: "342-342",
      indicator: "W",
      account_number: "3244654",
      amount: 10000, # Amount in cents
      account_name: "John Doe",
      transaction_code: 53,
      lodgement_reference: "R435564",
      trace_bsb: "453-543",
      trace_account_number: "45656733",
      name_of_remitter: "Remitter",
      witholding_amount: 100 # Amount in cents
    }
  )
end

puts aba.to_s # View output
File.write("/Users/me/dd_#{Time.now.to_i}.aba", aba.to_s) # or write output to file
```

There are a few ways to create a complete set of ABA data:

```ruby
# Transactions added to the defined ABA object variable
aba = Aba.batch financial_institution: 'ANZ', user_name: 'Joe Blow', user_id: 123456, process_at: 200615
aba.add_transaction bsb: '123-456', account_number: '000-123-456', amount: 50000
aba.add_transaction bsb: '456-789', account_number: '123-456-789', amount: '-10000', transaction_code: 13

# Transactions passed individually inside a block
aba = Aba.batch financial_institution: 'ANZ', user_name: 'Joe Blow', user_id: 123456, process_at: 200615 do |a|
  a.add_transaction bsb: '123-456', account_number: '000-123-456', amount: 50000
  a.add_transaction bsb: '456-789', account_number: '123-456-789', amount: '-10000', transaction_code: 13
end

# Transactions as an array passed to the second param of Aba.batch
aba = Aba.batch(
  { financial_institution: 'ANZ', user_name: 'Joe Blow', user_id: 123456, process_at: 200615 },
  [
    { bsb: '123-456', account_number: '000-123-456', amount: 50000 },
    { bsb: '456-789', account_number: '123-456-789', amount: '-10000', transaction_code: 13 }
  ]
)

# NOTE: Be careful with negative transaction amounts! transaction_code will not
#       be set to debit automatically!
```

Validation errors can be caught in several ways:

```ruby
# Create an ABA object with invalid character in the user_name
aba = Aba.batch(
  financial_institution: "ANZ",
  user_name: "Jøhn Doe",
  user_id: "123456",
  process_at: Time.now.strftime("%d%m%y")
)

# Add a transaction with a bad BSB
aba.add_transaction(
  bsb: "abc-123",
  account_number: "000123456"
)

# Is the data valid?
aba.valid?
# Returns: false

# Return a structured array of errors
puts aba.errors
# Returns:
# {:aba => ["user_name must not contain invalid characters"],
#  :transactions =>
#   {0 => ["bsb format is incorrect", "trace_bsb format is incorrect"]}}
```

Validation errors will stop parsing of the data to an ABA formatted string using
`to_s`. `aba.to_s` will raise a `RuntimeError` instead of returning output.


#### Parsing existing ABA file

```ruby
require 'aba'

collection = Aba.parse("/Users/me/dd_1443106832.aba")

collection.count # Number of batches

# Collection is just an array of batches
collection.each do |batch|
  batch.bsb
  batch.financial_institution
  batch.user_name
  batch.user_id
  batch.description
  batch.process_at
  
  batch.net_total_amount # Amount in cents
  batch.credit_total_amount # Amount in cents
  batch.debit_total_amount # Amount in cents
  batch.count # Number of transactions in the batch
  
  batch.transactions # Collection of transactions 
end
```

Parser errors will stop parsing rest of the ABA file and will raise
a `Aba::Parser::Error` exception with proper message instead of returning output.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/aba/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
