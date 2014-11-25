Addresses = require './addresses'
Transactions = require './transactions'

module.exports = class Account

  constructor: (accountResource, client) ->
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

  
  # NOTE: account.resource().transactions returns a funcrion
    #  not a resource. Could be a bug in Patchboard
  # transactions: ->
  #   transactionsResource = @resource().transactions
  #   @_transactions ||= new Transactions(transactionsResource, @client())

  








