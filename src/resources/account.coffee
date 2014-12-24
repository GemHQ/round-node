Addresses = require './addresses'
Transactions = require './transactions'
PaymentGenerator = require './payment_generator'

module.exports = class Account

  constructor: (accountResource, client, @wallet) ->
    @client = -> client
    @resource = -> accountResource

  # FIX: Currently receiving a 401
  # update: (content, callback) ->
  #   @resource().update content, (error, accountResource) ->
  #     return callback(error) if error

  #     @resource = -> accountResource

  #     return @


  addresses: (callback) ->
    return callback(null, @_addresses) if @_addresses
    
    addressesResource = @resource().addresses
    new Addresses addressesResource, @client(), (error, addresses) =>
      return callback(error) if error

      @_addresses = addresses
      callback null, @_addresses


  pay: (payees, callback) ->
    unless payees
      throw Error('Payees must be specified')

    multiwallet = @wallet._multiwallet
    unless multiwallet
      throw Error('You must unlock the wallet before attempting a transaction')

    @payments().unsigned payees, (error, payment) ->
      return callback(error) if error
      
      payment.sign multiwallet, (error, data) ->
        callback(error, data)
  
  # FIX: account.resource().transactions returns a function
    #  not a resource. Could be a bug in Patchboard
  # transactions: ->
  #   transactionsResource = @resource().transactions
  #   @_transactions ?= new Transactions(transactionsResource, @client())


  payments: -> @_payments ?= new PaymentGenerator(@resource().payments, @client())