
User = require './user'
CoinOp = require('coinop')
PassphraseBox = CoinOp.crypto.PassphraseBox
MultiWallet = CoinOp.bit.MultiWallet

Collection = require './collection'


module.exports = class Users extends Collection

  type: User
  
  # content requires email and wallet
  create: (content, callback) ->
    # ALERT: should the network be hardcoded to testnet?
    network = content.network || 'bitcoin_testnet'
    {email, passphrase} = content
    multiwallet = MultiWallet.generate(['primary', 'backup'], network)
    primarySeed = multiwallet.trees.primary.toBase58()
    encryptedSeed = PassphraseBox.encrypt(passphrase, primarySeed)
    wallet = {
      network,
      backup_public_seed: multiwallet.trees.backup.neutered().toBase58()
      primary_public_seed: multiwallet.trees.primary.neutered().toBase58()
      primary_private_seed: encryptedSeed
    }

    params = {email, default_wallet: wallet}
    @resource().create params, (error, resource) =>
      return callback(error) if error

      user = new User(resource, @client())

      callback(null, {multiwallet, user})
