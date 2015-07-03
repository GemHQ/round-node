Account = require './account'
Collection = require './collection'
Promise = require 'bluebird'
{promisify} = Promise


VALID_NETWORKS = ['bitcoin', 'bitcoin_testnet', 'litecoin', 'dogecoin']

module.exports = class Accounts extends Collection

  type: Account
  key: 'name'


  create: ({name, network}) ->
    if VALID_NETWORKS.indexOf(network) < 0
      return Promise.reject(new Error("Network must be one of the
                                following: #{VALID_NETWORKS.join(' ')}"))

    @resource.create = promisify(@resource.create)
    @resource.create(arguments[0])
    .then (resource) =>
      account = new Account({resource, @client, @wallet})
      @add(account)
      account
    .catch (error) -> throw new Error(error)