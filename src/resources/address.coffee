
module.exports = class Address

  constructor: ({resource, client}) ->
    @client = client
    @resource = resource
    {@path, @string, @subscriptions} = resource