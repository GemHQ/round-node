Wallet = require './wallet'

module.exports = class Wallets

  constructor: (walletsResource, client) ->
    @client = -> client
    @resource = -> walletsResource

  # Note: network can be either 'bitcoin_testnet', or 'bitcoin'
  create: (wallet, callback) ->
    @resource().create wallet, (error, walletResource) =>
      return callback(error) if error

      wallet = new Wallet walletResource, @client()
      walletName = walletResource.name
      @[walletName] = wallet
      
      callback(null, wallet)

