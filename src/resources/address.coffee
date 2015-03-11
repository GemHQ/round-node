
module.exports = class Address

  constructor: (resource, client, options) ->
    @client = -> client
    @resource = -> resource
    {@path, @string, @subscriptions} = resource