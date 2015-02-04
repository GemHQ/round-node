
module.exports = class Transaction

  constructor: (resource, client, options) ->
    @client = -> client
    @resource = -> resource