Wallet = require './wallet'
Collection = require './collection'

module.exports = class Wallets extends Collection

  type: Wallet

  # Note: network can be either 'bitcoin_testnet', or 'bitcoin'
  create: (wallet, callback) ->
    @resource().create wallet, (error, walletResource) =>
      return callback(error) if error

      wallet = new Wallet walletResource, @client()
      walletName = wallet.resource().name
      @collection[walletName] = wallet
      
      callback(null, wallet)

