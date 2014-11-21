
Account = require './account'
Collection = require './collection'


module.exports = class Accounts extends Collection

  type: Account

  # content must contain email
  create: (content, callback) ->
    @resource().create content, (error, accountResource) =>
      return callback(error) if error

      account = new Account accountResource, @client()
      @[content.name] = account
      callback null, account
