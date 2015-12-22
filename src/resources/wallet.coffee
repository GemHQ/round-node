Account = require('./account')
Accounts = require('./accounts')
Assets = require('./assets')
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


  assets: ({fetch} = {}) ->
    @getAssociatedCollection({
      collectionClass: Assets,
      name: 'asset_types',
      options: {
        wallet: @
      },
      fetch: fetch
    })


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
