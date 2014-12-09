Payment = require './payment'

module.exports = class PaymentGenerator

  constructor: (paymentResource) ->
    @resource = -> paymentResource

  unsigned: (payees, callback) ->
    unless payees?
      return callback(Error('Must supply a list of payees'))

    outputs = @outputsFromPayees(payees)
    @resource().create outputs, (error, paymentResource) ->
      return callback(error) if error
      
      callback(null, new Payment(paymentResource))

  outputsFromPayees: (payees) ->
    unless Array.isArray payees
      throw Error('Payees must be an array')

    outputs = payees.map (payee) ->
      throw Error('Bad output, no amount') unless payee.amount
      throw Error('Bad output, no address') unless payee.address
      {
        amount: payee.amount,
        payee: {address: payee.address}
      }

    {outputs}


