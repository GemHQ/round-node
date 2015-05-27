Addresses = require './addresses'
Transactions = require './transactions'
PaymentGenerator = require './payment_generator'
Base = require './base'

module.exports = class Account extends Base

  constructor: ({resource, client, wallet}) ->
    @client = client
    @resource = resource
    @wallet = wallet
    {@name, @balance, @path, @pending, @network} = resource


  addresses: (callback) ->
    @getAssociatedCollection({
      collectionClass: Addresses,
      name: 'addresses',
      callback: callback
    })


  pay: ({payees, confirmations, redirect_uri, mfa_token}, callback) ->

    unless payees
      return callback(new Error('Payees must be specified'))

    multiwallet = @wallet.multiwallet
    unless multiWallet?
      return callback(new Error('You must unlock the wallet before
                                 attempting a transaction'))

    network = @network
    @resource.transactions.create({payees, confirmations, redirect_uri},
      (error, payment) ->
        return callback(error) if error
        
        payment.sign({multiwallet, network})
    )



  transactions: (query, callback) ->
    if arguments.length == 1
      callback = arguments[0]
      query = {}
    
    @getAssociatedCollection({
      collectionClass: Transactions,
      name: 'transactions',
      resource: @resource.transactions(query)
      callback: callback
    })



  # # content takes a name property
  # update: (content, callback) ->
  #   @resource().update content, (error, resource) =>
  #     return callback(error) if error

  #     @resource = -> resource
  #     {@name} = resource

  #     callback(null, @)
