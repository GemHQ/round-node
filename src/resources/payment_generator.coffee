Payment = require './payment'

module.exports = class PaymentGenerator

  constructor: (paymentsResource, client) ->
    @resource = -> paymentsResource
    @client = -> client


  unsigned: (payees, confirmations, callback) ->
    unless payees?
      return callback(new Error('Must supply a list of payees'))

    confirmations ||= 6
    outputs = @outputsFromPayees(payees)

    @resource().create {outputs, confirmations}, (error, paymentResource) =>
      return callback(error) if error

      callback(null, new Payment(paymentResource, @client() ))


  outputsFromPayees: (payees) ->
    unless Array.isArray payees
      throw new Error('Payees must be an array')

    outputs = payees.map (payee) ->
      throw new Error('Bad output, no amount') unless payee.amount?
      throw new Error('Bad output, no address') unless payee.address?
      {
        amount: payee.amount,
        payee: {address: payee.address}
      }

    outputs
