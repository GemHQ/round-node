
module.exports = class Payment

  constructor: (resource, client) ->
    @resource = -> resource
    @client = -> client


  sign: (wallet, callback) ->
    {signatures, txHash} = wallet.prepareTransaction(@resource())
    signature = signatures[0]
    
    transactionContent = {
      transaction_hash: txHash,
      inputs: [{primary: signature}]
    }

    @resource().sign transactionContent, (error, data) ->
      callback(error, data)