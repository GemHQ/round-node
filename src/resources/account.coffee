Addresses = require './addresses'
Transactions = require './transactions'
PaymentGenerator = require './payment_generator'

module.exports = class Account

  constructor: (accountResource, client, options) ->
    @client = -> client
    @resource = -> accountResource
    @wallet = options.wallet


  addresses: (callback) ->
    return callback(null, @_addresses) if @_addresses
    
    resource = @resource().addresses

    addresses = new Addresses(resource, @client())
    
    addresses.loadCollection (error, addresses) =>
      return callback(error) if error

      @_addresses = addresses
      callback(null, @_addresses)


  pay: (payees, callback) ->
    unless payees
      return callback(new Error('Payees must be specified'))

    multiwallet = @wallet._multiwallet
    unless multiwallet
      return callback(new Error('You must unlock the wallet before attempting a transaction'))

    @payments().unsigned payees, (error, payment) ->
      return callback(error) if error
      
      payment.sign multiwallet, (error, data) ->
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