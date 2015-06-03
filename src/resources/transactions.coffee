Transaction = require './transaction'
Collection = require './collection'
Promise = require 'bluebird'
{promisify} = Promise


module.exports = class Transactions extends Collection

  type: Transaction


  create: ({payees, confirmations, redirect_uri}) ->
    unless payees
      return Promise.reject(new Error('Must have a list of payees')) 

    confirmations ?= 6

    @resource.create = promisify(@resource.create)
    @resource.create({
      utxo_confirmations: confirmations,
      payees: payees,
      redirect_uri: redirect_uri
    })
    .then (resource) =>
      payment = new Transaction({resource, @client})
    .catch (error) -> error
    

