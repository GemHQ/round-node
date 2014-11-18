
Rules = require './rules'

module.exports = class Wallet

  constructor: (client, walletResource) ->
    @client = -> client
    @resource = -> walletResource


  rules: () ->
    unless @_rules
      rulesResource = @resource().rules
      @_rules = new Rules @client(), rulesResource

    @_rules


