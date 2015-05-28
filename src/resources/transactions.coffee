
Transaction = require './transaction'
Collection = require './collection'


module.exports = class Transactions extends Collection

  type: Transaction


  create: ({payees, confirmations, redirect_uri}, callback) ->
    return callback(new Error('Must have a list of payees')) unless payees

    confirmations ?= 6

    @resource.create({
      utxo_confirmations: confirmations,
      payees: payees,
      redirect_uri: redirect_uri
    }, (error, resource) =>
      return callback(error) if error

      payment = new Transaction({resource, @client})
      callback(null, payment)
    )

