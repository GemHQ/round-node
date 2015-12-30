Addresses = require('./addresses')
Transactions = require('./transactions')
Base = require('./base')
Promise = require('bluebird')


module.exports = class Account extends Base

  constructor: ({resource, client, wallet}) ->
    @client = client
    @resource = resource
    @wallet = wallet
    {@name, @balance, @path, @pending, @network, @key,
    @pending_balance, @available_balance} = resource


  addresses: ({fetch} = {}) ->
    @getAssociatedCollection({
      collectionClass: Addresses,
      name: 'addresses',
      fetch: fetch
    })


  pay: ({payees, confirmations, redirect_uri, mfa_token}) ->
    unless payees
      return Promise.reject(new Error('Payees must be specified'))

    wallet = @wallet
    {multiwallet} = wallet
    unless multiwallet?
      return Promise.reject(new Error('You must unlock the wallet before
                                 attempting a transaction'))

    txs = new Transactions({resource: @resource.transactions({}), @client})
    txs.create({payees, confirmations, redirect_uri})
    .then (payment) -> payment.sign({wallet: multiwallet})
    .then (signedTx) ->
      if wallet.application?
        mfa_token ?= wallet.application.get_mfa()
        signedTx.approve({mfa_token})
        .then (signedTx) -> signedTx
      else
        signedTx
    .catch (error) -> throw new Error(error)


  transactions: ({fetch, query} = {}) ->
    @getAssociatedCollection({
      collectionClass: Transactions,
      name: 'transactions',
      fetch,
      query 
    })

