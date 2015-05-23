
User = require './user'
CoinOp = require('coinop-node')
PassphraseBox = CoinOp.crypto.PassphraseBox
MultiWallet = CoinOp.bit.MultiWallet

Collection = require './collection'


# When generating HDNodes, the netwrok does not really matter.
# The network is only used to create a serialized address.
# For the primary_public_seed, we send the API a base58 encocded
# master node. The API will strip out the netwrok specific data.
# Though, bitcoinjs still requires a netwrok. We default the network across
# all clients to 'bitcoin' for consistency sake.
NETWORK = 'bitcoin'


module.exports = class Users extends Collection

  type: User
  key: 'email'


  create: ({first_name, last_name, email,
           passphrase, device_name, redirect_uri}, callback) ->

    multiwallet = MultiWallet.generate(['primary'], NETWORK)
    primary_seed = multiwallet.trees.primary.seed
    encrypted_seed = PassphraseBox.encrypt(passphrase, primary_seed)
    wallet = {
      primary_public_seed: multiwallet.trees.primary.neutered().toBase58()
      primary_private_seed: encrypted_seed
      name: 'default'
    }

    params = {email, first_name, last_name, default_wallet: wallet, device_name}
    params.redirect_uri = redirect_uri if redirect_uri?

    @resource.create params, (error, resource) ->
      return callback(error) if error

      callback(null, {device_token: resource.metadata.device_token})
