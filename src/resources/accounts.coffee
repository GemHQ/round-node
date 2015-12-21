Account = require './account'
Collection = require './collection'
Promise = require 'bluebird'
{promisify} = Promise


VALID_NETWORKS = ['bitcoin', 'bitcoin_testnet', 'litecoin', 'dogecoin', 'bcy']

module.exports = class Accounts extends Collection

  type: Account
  key: 'name'


  create: ({name, network}) ->
    if VALID_NETWORKS.indexOf(network) < 0
      return Promise.reject(new Error("Network must be one of the
                                following: #{VALID_NETWORKS.join(' ')}"))

    rsrc = @resource({})
    rsrc.create = promisify(rsrc.create)
    rsrc.create(arguments[0])
    .then (resource) =>
      account = new Account({resource, @client, @wallet})
      @add(account)
      account
    .catch (error) -> throw new Error(error)


  # First searches the cached hash. If that doesn't exist
  # then it performs a query.
  get: (name) ->
    super(name)
    .then (account) -> account
    .catch (error) =>
      res = @wallet.resource.account_query({name})
      res.get = promisify(res.get)
      res.get()
      .then (resource) =>
        account = new Account({resource, client: @client, wallet: @wallet})
        @add(account)
        account
      .catch (error) ->
        throw new Error(error)