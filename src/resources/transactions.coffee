
# does not inherit from Collection because we do
# not need to call .list when receiving a transactions object
module.exports = class Transactions

  constructor: (txResource, client) ->
    @client = -> client
    @resource = -> txResource

