Base = require('./base')

module.exports = class Transaction extends Base

  @PROPS_LIST: ['value', 'fee', 'confirmations', 'hash', 'status', 'inputs',
                'outputs', 'destination_address', 'lock_time', 'network']

  constructor: ({resource, client}) ->
    @client = client
    @resource = resource
    @_setProps(Transaction.PROPS_LIST, resource)
    # {@value, @fee, @confirmations, @hash, @status, @inputs,
    # @outputs, @destination_address, @lock_time, @network} = resource


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
      signatures: {
        transaction_hash: txHash,
        inputs: [{primary: signature}]
      }
    }
    @resource.update txContent, (error, resource) =>
      return callback(error) if error

      @resource = resource
      callback(null, @)


  approve: ({mfa_token}, callback) ->
    @client.context.setMFA(mfa_token)
    @resource.approve {}, (error, resource) =>
      return callback(error) if error

      @resource = resource
      @_setProps(Transaction.PROPS_LIST, resource)
      callback(null, @)


  cancel: (callback) ->
    @resource.cancel (error, resource) =>
      return callback(error) if error

      @resource = resource
      @_setProps(Transaction.PROPS_LIST, resource)
      callback(null, @)
