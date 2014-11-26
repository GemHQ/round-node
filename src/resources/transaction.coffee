
module.exports = class Transaction

  constructor: (txResource, client) ->
    @client = -> client
    @resource = -> txResource