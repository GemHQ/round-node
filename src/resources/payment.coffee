
module.exports = class Payment

  constructor: (resource, client) ->
    @resource = -> resource
    @client = -> client


  sign: (wallet, callback) ->
    {signatures, txHash} = wallet.prepareTransaction(@resource())
    signature = signatures[0]

    # Use this when you have more coins to test
    # signatures = signatures.map (signature) ->
    #   {primary: signature}
    
    transactionContent = {
      transaction_hash: txHash,
      inputs: [{primary: signature}]
      # use this when you uncomment changes above
      # inputs: signatures
    }

    @resource().sign transactionContent, (error, data) ->
      callback(error, data)