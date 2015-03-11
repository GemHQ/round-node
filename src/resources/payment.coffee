
module.exports = class Payment

  constructor: (resource, client, options) ->
    @resource = -> resource
    @client = -> client
    {@outputs, @confirmations, @fee} = resource


  sign: (wallet, callback) ->
    {signatures, txHash} = wallet.prepareTransaction(@resource())

    # Currently just using the first (and only) signature
    # Eventually this needs to account for more than one signature
    signature = signatures[0]

    transactionContent = {
      transaction_hash: txHash,
      inputs: [{primary: signature}]
    }

    @resource().sign transactionContent, (error, data) ->
      callback(error, data)
