
Account = require './account'
Collection = require './collection'


module.exports = class Accounts extends Collection

  constructor: (resource, client, callback, @wallet) ->
    super

  type: Account

  # Content requires an name
  create: (content, callback) ->
    @resource().create content, (error, accountResource) =>
      return callback(error) if error

      account = new Account accountResource, @client(), @wallet
      
      @add(content.name, account)
      
      callback null, account
