Wallet = require './wallet'
Collection = require './collection'
CoinOp = require('coinop')
PassphraseBox = CoinOp.crypto.PassphraseBox
MultiWallet = CoinOp.bit.MultiWallet

module.exports = class Wallets extends Collection

  type: Wallet

  # Note: network can be either 'bitcoin_testnet', or 'bitcoin'
  # Content requires name and passphrase
  create: (content, callback) ->
    {name, passphrase} = content

    return callback(new Error('Must provide a passphrase')) unless passphrase
    return callback(new Error('Must provide a name')) unless name

    network = content.network || 'bitcoin_testnet'
    multiwallet = MultiWallet.generate(['primary', 'backup'], network)
    primarySeed = multiwallet.trees.primary.toBase58()
    encryptedSeed = PassphraseBox.encrypt(passphrase, primarySeed)

    walletData = {
      name: name,
      network: network,
      backup_public_seed: multiwallet.trees.backup.neutered().toBase58(),
      primary_public_seed: multiwallet.trees.primary.neutered().toBase58(),
      primary_private_seed: encryptedSeed
    }

    @resource().create walletData, (error, resource) =>
      return callback(error) if error

      wallet = new Wallet(resource, @client())
      @collection[name] = wallet

      callback(null, wallet)




    # @resource().create wallet, (error, walletResource) =>
    #   return callback(error) if error

    #   wallet = new Wallet walletResource, @client()
    #   walletName = wallet.resource().name
    #   @collection[walletName] = wallet
      
    #   callback(null, wallet)

