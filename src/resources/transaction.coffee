
module.exports = class Transaction

  constructor: ({resource, client}) ->
    @client = client
    @resource = resource
    {@data, @confirmations, @hash} = resource


  sign: ({wallet}, callback) ->
    unless @resource.status == 'unsigned'
      callback(new Error('Transaction is already signed'))

    unless wallet?
      callback(new Error('A wallet is required to sign a transaction'))

    {signatures, txHash} = wallet.prepareTransaction(@resource)
    
    # Currently just using the first (and only) signature
    # Eventually this needs to account for more than one signature
    signature = signatures[0]

    txContent = {
      transaction_hash: txHash,
      inputs: [{primary: signature}]
    }
    @resource.update txContent, (error, resource) =>
      console.log "+++++++++++++++++++++++++++++++"
      console.log error
      console.log "+++++++++++++++++++++++++++++++"
      return callback(error) if error

      @resource = resource
      callback(null, @)


  approve: ({mfa_token}, callback) ->
    @client.context.setMFA(mfa_token)
    @resource.approve (error, data) ->
      callback(error, data)
