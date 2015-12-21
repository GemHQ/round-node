User = require './user'
CoinOp = require('coinop-node')
{promisify} = require('bluebird')
PassphraseBox = CoinOp.crypto.PassphraseBox
PassphraseBox.encrypt = promisify(PassphraseBox.encrypt)
MultiWallet = CoinOp.bit.MultiWallet
Collection = require './collection'


# When generating HDNodes, the netwrok does not really matter.
# The network is only used to create a serialized address.
# Though, bitcoinjs still requires a network. We default the network across
# all clients to 'bitcoin' for consistency sake.
# For the primary_public_seed, we send the API a base58 encocded
# master node. The API will strip out the network specific data.
NETWORK = 'bitcoin'


module.exports = class Users extends Collection

  type: User
  key: 'email'


  create: ({first_name, last_name, email,
           passphrase, device_name, redirect_uri}) ->

    multiwallet = MultiWallet.generate(['primary'], NETWORK)
    primary_seed = multiwallet.trees.primary.seed.toString('hex')
    PassphraseBox.encrypt({passphrase, plaintext: primary_seed})
      .then (encrypted_seed) =>
        wallet = {
          primary_public_seed: multiwallet.trees.primary.neutered().toBase58()
          primary_private_seed: encrypted_seed
          name: 'default'
        }

        params = {email, first_name, last_name, default_wallet: wallet, device_name}
        params.redirect_uri = redirect_uri if redirect_uri?

        rsrc = @resource({})
        rsrc.create = promisify(rsrc.create)
        rsrc.create(params)
          .then (resource) -> resource.metadata.device_token 
          .catch (error) -> throw new Error(error)
