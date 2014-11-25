
module.exports = class Address

  constructor: (addressResource, client) ->
    @client = -> client
    @resource = -> addressResource