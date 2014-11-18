Wallet = require './wallet'

module.exports = class Wallets

  constructor: (client, walletResource) ->
    @client = -> client
    @resource = -> walletResource

  # Note: network can be either 'bitcoin_testnet', or 'bitcoin'
  create: (wallet, callback) ->
    @resource().create wallet, (error, walletResource) =>
      return callback(error) if error

      wallet = new Wallet @client(), walletResource
      walletName = walletResource.name 
      @[walletName] = wallet
      
      callback(null, wallet)

