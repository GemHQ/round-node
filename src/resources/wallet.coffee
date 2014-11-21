
Rules = require './rules'
Accounts = require './accounts'

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
    new Accounts accountsResource, @client(), (error, accounts) =>
      return callback(error) if error

      @_accounts = accounts
      callback null, @_accounts

