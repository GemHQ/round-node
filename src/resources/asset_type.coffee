Transactions = require('./transactions')
Transaction = require('./transaction')
Base = require('./base')
Promise = require('bluebird')
{promisify} = Promise


module.exports = class AssetType extends Base

  constructor: ({resource, client, wallet}) ->
    @client = client
    @resource = resource
    @wallet = wallet
    {@name, @network, @protocol, @fungible, @locked} = resource



  transactions: ({fetch} = {}) ->
    @getAssociatedCollection({
      collectionClass: Transactions,
      name: 'transactions',
      fetch: fetch
    })


  transfer: ({outputs}) ->
    @resource.transfer = promisify(@resource.transfer)
    @resource.transfer({outputs})
      .then (resource) => new Transaction({resource, @client})
      .catch (error) -> throw new Error(error)


  issue: ({outputs}) ->
    @resource.issue = promisify(@resource.issue)
    @resource.issue({outputs})
      .then (resource) => new Transaction({resource, @client})
      .catch (error) -> throw new Error(error)

