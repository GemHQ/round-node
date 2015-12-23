Account = require('./account')
Accounts = require('./accounts')
AssetTypes = require('./asset_types')
Base = require('./base')
CoinOp = require 'coinop-node'
{promisify} = require('bluebird')
PassphraseBox = CoinOp.crypto.PassphraseBox
PassphraseBox.decrypt = promisify(PassphraseBox.decrypt)
MultiWallet = CoinOp.bit.MultiWallet


module.exports = class Wallet extends Base

  constructor: ({resource, client, multiwallet, application}) ->
    @client = client
    @resource = resource
    # if @ is a newly created wallet, then it has access to the master node
    # via the passed multiwallet. However, if this wallet object is being pulled
    # down from the api it needs to be unlocked. @unlock will reset @multiwallet
    @multiwallet = multiwallet
    @application = application
    {@name, @cosigner_public_seed, @backup_public_seed, @key,
    @primary_public_seed, @balance, @default_account, @transactions} = resource


  accounts: ({fetch} = {}) ->
    @getAssociatedCollection({
      collectionClass: Accounts,
      name: 'accounts',
      options: {
        wallet: @
      },
      fetch: fetch
    })


  assetTypes: ({fetch} = {}) ->
    @getAssociatedCollection({
      collectionClass: AssetTypes,
      name: 'asset_types',
      options: {
        wallet: @
      },
      fetch: fetch
    })


  # takes the asset_type key, returns your balance for that
  # asset type.
  balancesFor: ({asset_type, utxo_confirmations, network}) ->
    if !asset_type
      throw new Error('You must supply asset_type: key')

    utxo_confirmations ?= 0
    network ?= 'bcy'
    @resource.available = promisify(@resource.available)
    @resource.available({asset_type, utxo_confirmations, network})
      .then (balanceData) -> balanceData
      .catch (error) -> throw new Error(error)




  account: ({name}) ->
    @accounts()
    .then (accounts) -> accounts.get(name)
    .catch (error) -> throw new Error(error)


  unlock: ({passphrase}) ->
    PassphraseBox.decrypt({passphrase, encrypted: @resource.primary_private_seed})
    .then (primary_seed) =>
      @multiwallet = new MultiWallet({
        private: {
          primary: primary_seed
        },
        public: {
          cosigner: @resource.cosigner_public_seed,
          backup: @resource.backup_public_seed
        }
      })
      return @
    .catch (error) -> throw new Error(error)


  backup_key: ->
    @multiwallet.trees.backup.seed.toString('hex')
