
Account = require './account'

module.exports = class Accounts

  constructor: (accountsResource, client, callback) ->
    @client = -> client
    @resource = -> accountsResource

  # content must contain email
  create: (content, callback) ->
    @resource().create content, (error, accountResource) =>
      return callback(error) if error

      account = new Account accountResource, @client()
      @[content.name] = account
      callback null, account

