
Accounts = require './accounts'
CoinOp = require 'coinop-node'
PassphraseBox = CoinOp.crypto.PassphraseBox
MultiWallet = CoinOp.bit.MultiWallet

module.exports = class Wallet

  constructor: (resource, client, options) ->
    @client = -> client
    @resource = -> resource
    # gets set in @unlock
    @multiWallet = null
    {@name, @network, @cosigner_public_seed, @backup_public_seed,
    @primary_public_seed, @balance, @default_account,
    @subscriptions, @transactions} = resource


  rules: () ->
    unless @_rules
      rulesResource = @resource().rules
      @_rules = new Rules rulesResource, @client()

    @_rules


  accounts: (callback) ->
    return callback(null, @_accounts) if @_accounts

    resource = @resource().accounts

    accounts = new Accounts(resource, @client(), @)

    accounts.loadCollection {wallet: @}, (error, accounts) =>
      return callback(error) if error

      @_accounts = accounts
      callback(null, @_accounts)


  unlock: (passphrase) ->
    primary_seed = PassphraseBox.decrypt(passphrase, @resource().primary_private_seed)
    @multiWallet = new MultiWallet {
      private: {
        primary: primary_seed
      },
      public: {
        cosigner: @resource().cosigner_public_seed,
        backup: @resource().backup_public_seed
      }
    }


  # content takes a name property
  update: (content, callback) ->
    @resource().update content, (error, resource) =>
      return callback(error) if error

      @resource = -> resource
      @name = resource.name

      callback(null, @)


  # Note: Not yet implamented on the API
  # reset: (callback) ->
  #   @resource().reset (error, resource) =>
  #     return callback(error) if error

  #     newWallet = new Wallet(resource, client())

  #     callback(null, newWallet)
