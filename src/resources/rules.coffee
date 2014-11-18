
module.exports = class Rules

  constructor: (client, rulesResource) ->
    @client = -> client
    @resource = -> rulesResource

  