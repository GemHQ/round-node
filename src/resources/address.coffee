
module.exports = class Address

  constructor: (addressResource, client, options) ->
    @client = -> client
    @resource = -> addressResource