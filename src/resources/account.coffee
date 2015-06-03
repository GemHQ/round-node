Addresses = require('./addresses')
Transactions = require('./transactions')
Base = require('./base')
Promise = require('bluebird')


module.exports = class Account extends Base

  constructor: ({resource, client, wallet}) ->
    @client = client
    @resource = resource
    @wallet = wallet
    {@name, @balance, @path, @pending, @network,
    @pending_balance, @available_balance} = resource


  addresses: ->
    @getAssociatedCollection({
      collectionClass: Addresses,
      name: 'addresses'
    })


  pay: ({payees, confirmations, redirect_uri, mfa_token}) ->
    unless payees
      return Promise.reject(new Error('Payees must be specified'))

    wallet = @wallet
    {multiwallet} = wallet
    unless multiwallet?
      return Promise.reject(new Error('You must unlock the wallet before
                                 attempting a transaction'))

    tx = new Transactions({resource: @resource.transactions({}), @client})
    tx.create({payees, confirmations, redirect_uri})
    .then (payment) -> payment.sign({wallet: multiwallet})
    .then (signedTx) ->
      if wallet.application?
        mfa_token ?= wallet.application.get_mfa()
        signedTx.approve({mfa_token})
        .then (signedTx) -> signedTx
      else
        signedTx


  transactions: (query={}) ->
    @getAssociatedCollection({
      collectionClass: Transactions,
      name: 'transactions',
      resource: @resource.transactions(query)
    })

