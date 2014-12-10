
Rules = require './rules'
Accounts = require './accounts'
CoinOp = require 'coinop'
PassphraseBox = CoinOp.crypto.PassphraseBox
MultiWallet = CoinOp.bit.MultiWallet

module.exports = class Wallet

  constructor: (walletResource, client) ->
    @client = -> client
    @resource = -> walletResource


  rules: () ->
    unless @_rules
      rulesResource = @resource().rules
      @_rules = new Rules rulesResource, @client()

    @_rules


  accounts: (callback) ->
    return callback(null, @_accounts) if @_accounts

    accountsResource = @resource().accounts
    new Accounts accountsResource, @client(), ((error, accounts) =>
      return callback(error) if error

      @_accounts = accounts
      callback null, @_accounts), @ #accounts takes a wallet

  unlock: (passphrase) ->
    primary_seed = PassphraseBox.decrypt(passphrase, @resource().primary_private_seed)
    @_multiwallet = new MultiWallet {
      private: {
        primary: primary_seed
      },
      public: {
        cosigner: @resource().cosigner_public_seed,
        backup: @resource().backup_public_seed
      }
    }