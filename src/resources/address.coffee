
module.exports = class Address

  constructor: (resource, client, options) ->
    @client = -> client
    @resource = -> resource
    @path = resource.path
    @string = resource.string