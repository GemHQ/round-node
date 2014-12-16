
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
    network = 'testnet'
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

    params = {email, wallet}
    @resource().create params, (error, userResource) =>
      return callback(error) if error

      user = new User(userResource, @client())
      # the key is a reference to the resource's name
      # therefor it should update when the resource updates.
      @collection[user.resource().name] = user
      callback(null, {multiwallet, user})
