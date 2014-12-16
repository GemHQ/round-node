
module.exports = class Payment

  constructor: (resource, client) ->
    @resource = -> resource
    @client = -> client


  # sign: (wallet, callback) ->
  #   unless wallet
  #     throw Error('A wallet is required to sign a transaction')

  #   # ALERT: not checking if its a valid output
  #     # Ex: https://github.com/GemHQ/round-rb/blob/master/lib/round/payment.rb#L8

  #   tx = new bitcoin.Transaction()
  #   paymentResource = payment.resource()
    
  #   paymentResource.inputs.forEach (input) ->
  #     prevTx = input.output.transaction_hash
  #     index = input.output.index
  #     tx.addInput(prevTx, index)

  #   paymentResource.outputs.forEach (output) ->
  #     address = output.address
  #     value = output.value
  #     tx.addOutput(address, value)

  #   @resource.sign({
  #     transaction_hash: tx.getHash # or is it .getHex
  #     inputs: 
  #   })
    



    