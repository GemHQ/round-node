
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
    @_accounts || @_accounts = new Accounts @resource().accounts, @client(), callback

