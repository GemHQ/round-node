
module.exports = class Subscription

  constructor: (resource, client) ->
    @resource = -> resource
    client = -> client