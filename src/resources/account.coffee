
module.exports = class Account

  constructor: (client, accountResource) ->
    @client = -> client
    @resource = -> accountResource

  