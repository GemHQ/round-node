Addresses = require './addresses'
Transactions = require './transactions'
PaymentGenerator = require './payment_generator'

module.exports = class Account

  constructor: (resource, client, options) ->
    @client = -> client
    @resource = -> resource
    {@name, @balance, @path, @pending, @rules, @subscriptions} = resource
    @wallet = options.wallet


  addresses: (callback) ->
    return callback(null, @_addresses) if @_addresses

    resource = @resource().addresses

    addresses = new Addresses(resource, @client())

    addresses.loadCollection (error, addresses) =>
      return callback(error) if error

      @_addresses = addresses
      callback(null, @_addresses)


  # content requires payees
  pay: (content, callback) ->
    {payees, confirmations} = content

    unless payees
      return callback(new Error('Payees must be specified'))

    confirmations ||= 6

    multiWallet = @wallet.multiWallet
    unless multiWallet
      return callback(new Error('You must unlock the wallet before attempting a transaction'))

    @payments().unsigned payees, confirmations, (error, payment) ->
      return callback(error) if error

      payment.sign multiWallet, (error, data) ->
        callback(error, data)


  transactions: (callback) ->
    return callback(null, @_transactions) if @_transactions

    resource = @resource().transactions({}) # Must pass a hash

    transactions = new Transactions(resource, @client())

    transactions.loadCollection (error, transactions) =>
      return callback(error) if error

      @_transactions = transactions
      callback(null, @_transactions)


  payments: -> @_payments ?= new PaymentGenerator(@resource().payments, @client())


  # content takes a name property
  update: (content, callback) ->
    @resource().update content, (error, resource) =>
      return callback(error) if error

      @resource = -> resource
      {@name} = resource

      callback(null, @)
