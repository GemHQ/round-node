
Account = require './account'
Collection = require './collection'


VALID_NETWORKS = ['bitcoin', 'bitcoin_testnet', 'litecoin', 'dogecoin']


module.exports = class Accounts extends Collection


  type: Account
  key: 'name'


  create: ({name, network}, callback) ->
    if VALID_NETWORKS.indexOf(network) < 0
      return callback(new Error("Network must be one of the
                                following: #{VALID_NETWORKS.join(' ')}"))

    @resource.create arguments[0], (error, resource) =>
      return callback(error) if error

      account = new Account({resource, @client, @wallet})
      @add(account)

      callback(null, account)
