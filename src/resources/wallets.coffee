Wallet = require './wallet'
Collection = require './collection'
CoinOp = require('coinop-node')
Promise = require('bluebird')
{promisify} = Promise
PassphraseBox = CoinOp.crypto.PassphraseBox
PassphraseBox.encrypt = promisify(PassphraseBox.encrypt)
MultiWallet = CoinOp.bit.MultiWallet


# When generating HDNodes, the network does not matter.
# The network is only used to create a serialized address.
# For the primary_public_seed, we send the API a base58 encoded
# master node. The API will strip out the network specific data.
# Though, bitcoinjs still requires a network. We default the network
# across all clients to 'bitcoin' for consistency sake.
NETWORK = 'bitcoin'


module.exports = class Wallets extends Collection

  type: Wallet
  key: 'name'

  
  create: ({name, passphrase, multiwallet}) ->
    unless passphrase
      return Promise.reject(new Error('Must provide a passphrase'))
    unless name
      return Promise.reject(new Error('Must provide a name'))

    multiwallet ?= MultiWallet.generate(['primary', 'backup'], NETWORK)
    primarySeed = multiwallet.trees.primary.seed.toString('hex')
    PassphraseBox.encrypt({passphrase, plaintext: primarySeed})
      .then (encryptedSeed) =>
        backup_seed = multiwallet.trees.backup.seed.toString('hex')

        walletData = {
          name: name,
          backup_public_seed: multiwallet.trees.backup.neutered().toBase58(),
          primary_public_seed: multiwallet.trees.primary.neutered().toBase58(),
          primary_private_seed: encryptedSeed
        }

        @resource.create = promisify(@resource.create)
        @resource.create(walletData)
          .then (resource) =>
            wallet = new Wallet({resource, @client, multiwallet, @application})
            @add(wallet)

            {wallet, backup_seed}
          .catch (error) -> throw new Error(error)


  # First searches the cached hash. If that doesn't exist
  # then it performs a query.
  get: (name) ->
    super(name)
    .then (wallet) -> wallet
    .catch (error) =>
      if @application
        res = @application.resource.wallet_query({name})
        res.get = promisify(res.get)
        res.get()
        .then (resource) =>
          wallet = new Wallet({resource, client: @client, application: @application})
          @add(wallet)
          wallet
        .catch (error) ->
          throw new Error(error)
      else
        throw new Error(error)


