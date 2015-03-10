
module.exports = class Rules

  constructor: (rulesResource, client) ->
    @client = -> client
    @resource = -> rulesResource
