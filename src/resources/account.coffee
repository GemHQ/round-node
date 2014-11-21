
module.exports = class Account

  constructor: (accountResource, client) ->
    
    @client = -> client
    @resource = -> accountResource

