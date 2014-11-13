
module.exports = class Wallets

  constructor: (client, walletResource) ->
    @client = -> client
    @resource = -> walletResource

