
User = require './user'
coinop = require('coinop')
PassphraseBox = coinop.crypto.PassphraseBox
MultiWallet = coinop.bit.MultiWallet

Collection = require './collection'


module.exports = class Users extends Collection

  type: User
  
  # content requires email and wallet
  create: (content, callback) ->
    {email, passphrase} = content
    multiwallet = MultiWallet.generate(['primary', 'backup'])
    # ALERT: should the network be hardcoded to testnet?
    network = 'bitcoin_testnet'
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
      # ALERT: do we want to return the multiwallet?
      #        why not return just the user?
      callback(null, {multiwallet, user})
