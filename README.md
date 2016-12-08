[![Build Status](https://travis-ci.org/andrba/aba.svg?branch=master)](https://travis-ci.org/andrba/aba) [![Code Climate](https://codeclimate.com/github/andrba/aba/badges/gpa.svg)](https://codeclimate.com/github/andrba/aba)

# Aba

A library for handling ABA (Australian Banking Association) files.

## Installation

Add this line to your application's Gemfile:

    gem 'aba'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aba

## Usage

#### Working with batch

Create a new batch:

```ruby
require 'aba'

aba = Aba.batch(
  bsb: "123-345", # Optional (Not required by NAB)
  financial_institution: "WPC",
  user_name: "John Doe",
  user_id: "466364",
  description: "Payroll",
  process_at: Time.now.strftime("%d%m%y")
)
```

Validate a batch:

```ruby
aba = Aba.batch

aba.valid?
# Returns: false

# Return a structured array of errors:
aba.errors
# Returns:
#   {
#       :aba => [
#           [0] "financial_institution length must be exactly 3 characters",
#           [1] "user_name is empty",
#           [2] "user_id is empty",
#           [3] "user_id must be an unsigned number",
#           [4] "process_at length must be exactly 6 characters",
#           [5] "process_at must be an unsigned number"
#       ]
#   }
```

List of batch errors can include also list of trasaction errors if such was added.

#### Working with transactions

Create a new transaction:

```ruby
transaction = Aba::Transaction.new(
    bsb: "342-342",
    account_number: "3244654",
    indicator: "W",
    amount: 10000, # Amount in cents
    account_name: "John Doe",
    transaction_code: 53,
    lodgement_reference: "R435564",
    trace_bsb: "453-543",
    trace_account_number: "45656733",
    name_of_remitter: "Remitter",
    witholding_amount: 100 # Amount in cents
)
```

Validate a transaction:

```ruby
transaction = Aba::Transaction.new

transaction.valid?
# Returns: false

# Return a structured array of errors:
transaction.errors
# Returns:
#    [
#        [0] "bsb format is incorrect",
#        [1] "account_number must be a valid account number",
#        [2] "trace_bsb format is incorrect",
#        [3] "trace_account_number must be a valid account number"
#    ]
```

There are a few ways to add transactions to a batch

Transactions can be added to the defined ABA object variable:

```ruby
aba.add_transaction(
    {
        bsb: "342-342",
        account_number: "3244654",
        indicator: "W",
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
```

Transactions can be passed individually inside a block while creating a batch:

```ruby
aba = Aba.batch financial_institution: 'ANZ', user_name: 'John Doe', user_id: 123456, process_at: 200615 do |a|
  a.add_transaction bsb: '123-456', account_number: '000-123-456', amount: 50000, transaction_code: 50
  a.add_transaction bsb: '456-789', account_number: '123-456-789', amount: 10000, transaction_code: 13
end
```

Transactions can be an array passed to the second param of `Aba.batch`:

```ruby
aba = Aba.batch(
  { financial_institution: 'ANZ', user_name: 'Joe Blow', user_id: 123456, process_at: 200615 },
  [
    { bsb: '123-456', account_number: '000-123-456', amount: 50000, transaction_code: 50 },
    { bsb: '456-789', account_number: '123-456-789', amount: 10000, transaction_code: 13 }
  ]
)
```

#### Working with batch output

View output

```ruby
puts aba.to_s
```

Write output to file

```ruby
File.write("/Users/me/dd_#{Time.now.to_i}.aba", aba.to_s) # 
```

Validation errors will stop parsing of the data to an ABA formatted string using
`to_s`. `aba.to_s` will raise a `RuntimeError` instead of returning output.

#### Parsing existing ABA file

Library for parsing accepts open stream which could be a file or SFTP connection:

```ruby
filepath = "/Users/me/dd_1443106832.aba"
file = File.open(filepath, "r")

collection = Aba.parse(file)
# Returns:
#   [
#       [0] #<Aba::Batch:0x007fb1d2816f88 @bsb="987-654" ... >,
#       [1] #<Aba::Batch:0x007fb1d11385c8 @bsb="123-456" ... >
#   ]
```

The library also accepts a block of text:
```ruby
filepath = "/Users/me/dd_1443106832.aba"
text = File.read(filepath)

collection = Aba.parse(text)
# Returns:
#   [
#       [0] #<Aba::Batch:0x007fb1d2816f88 @bsb="987-654" ... >,
#       [1] #<Aba::Batch:0x007fb1d11385c8 @bsb="123-456" ... >
#   ]
```

Returned collection is just an array of ABA objects with transactions:

```ruby
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
