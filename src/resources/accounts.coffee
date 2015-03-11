
Account = require './account'
Collection = require './collection'


module.exports = class Accounts extends Collection

  constructor: (resource, client, @wallet) ->
    super


  type: Account
  key: 'name'


  # Content requires an name
  create: (content, callback) ->
    @resource().create content, (error, accountResource) =>
      return callback(error) if error

      account = new Account accountResource, @client(), @wallet

      @add(account)

      callback null, account
