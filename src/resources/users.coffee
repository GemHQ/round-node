
User = require './user'
CoinOp = require('coinop-node')
PassphraseBox = CoinOp.crypto.PassphraseBox
MultiWallet = CoinOp.bit.MultiWallet

Collection = require './collection'


module.exports = class Users extends Collection

  type: User

  # content requires email and wallet
  create: ({first_name, last_name, email,
           passphrase, device_name, redirect_uri}, callback) ->
    network = @client.network
    {email, passphrase} = content
    multiwallet = MultiWallet.generate(['primary', 'backup'], network)
    primary_seed = multiwallet.trees.primary.toBase58()
    encrypted_seed = PassphraseBox.encrypt(passphrase, primary_seed)
    wallet = {
      network,
      backup_public_seed: multiwallet.trees.backup.neutered().toBase58()
      primary_public_seed: multiwallet.trees.primary.neutered().toBase58()
      primary_private_seed: encrypted_seed
      name: 'default'
    }

    params = {email, default_wallet: wallet}
    @resource.create params, (error, resource) =>
      return callback(error) if error

      user = new User(resource, @client)

      backup_seed = multiwallet.trees.backup.toBase58()
      callback(null, backup_seed, user)
