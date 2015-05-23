Wallet = require './wallet'
Collection = require './collection'
CoinOp = require('coinop-node')
PassphraseBox = CoinOp.crypto.PassphraseBox
MultiWallet = CoinOp.bit.MultiWallet


# When generating HDNodes, the netwrok does not really matter.
# The network is only used to create a serialized address.
# For the primary_public_seed, we send the API a base58 encocded
# master node. The API will strip out the netwrok specific data.
# Though, bitcoinjs still requires a netwrok. We default the network across
# all clients to 'bitcoin' for consistency sake.
NETWORK = 'bitcoin'


module.exports = class Wallets extends Collection

  type: Wallet
  key: 'name'

  
  create: ({name, passphrase, multiwallet}, callback) ->

    return callback(new Error('Must provide a passphrase')) unless passphrase
    return callback(new Error('Must provide a name')) unless name

    multiwallet ?= MultiWallet.generate(['primary', 'backup'], NETWORK)
    primarySeed = multiwallet.trees.primary.seed.toString('hex')
    backup_seed = multiwallet.trees.primary.toBase58()
    encryptedSeed = PassphraseBox.encrypt(passphrase, primarySeed)

    walletData = {
      name: name,
      backup_public_seed: multiwallet.trees.backup.neutered().toBase58(),
      primary_public_seed: multiwallet.trees.primary.neutered().toBase58(),
      primary_private_seed: encryptedSeed
    }

    @resource.create walletData, (error, resource) =>
      return callback(error) if error

      wallet = new Wallet({resource, @client, multiwallet, @application})

      @add(wallet)

      callback(null, backup_seed, wallet)
