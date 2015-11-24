Base = require('./base')
Promise = require('bluebird')
{promisify} = Promise


module.exports = class Transaction extends Base

  @PROPS_LIST: ['value', 'fee', 'confirmations', 'hash', 'status', 'inputs',
                'outputs', 'destination_addresses', 'lock_time', 'network', 'mfa_uri']

  constructor: ({resource, client}) ->
    @client = client
    @resource = resource
    @_setProps(Transaction.PROPS_LIST, resource)


  sign: ({wallet}) ->
    unless @resource.status == 'unsigned'
      Promise.reject(new Error('Transaction is already signed'))

    unless wallet?
      Promise.reject(new Error('A wallet is required to sign a transaction'))

    {signatures, txHash} = wallet.prepareTransaction(@resource)
    
    inputs = signatures.map (sig) ->
      {primary: sig}

    txContent = {
      signatures: {
        transaction_hash: txHash,
        inputs: inputs
      }
    }
    @resource.update = promisify(@resource.update)
    @resource.update(txContent)
    .then (resource) => 
      @resource = resource
      @_setProps(Transaction.PROPS_LIST, resource)
      @
    .catch (error) -> throw new Error(error)


  approve: ({mfa_token}) ->
    @client.context.setMFA(mfa_token)
    @resource.approve = promisify(@resource.approve)
    @resource.approve({})
    .then (resource) =>
      @resource = resource
      @_setProps(Transaction.PROPS_LIST, resource)
      @
    .catch (error) -> throw new Error(error)


  cancel: ->
    @resource.cancel = promisify(@resource.cancel)
    @resource.cancel()
    .then (resource) =>
      @resource = resource
      @_setProps(Transaction.PROPS_LIST, resource)
      @
    .catch (error) -> throw new Error(error)