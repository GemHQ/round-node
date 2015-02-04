
Wallets = require './wallets'
MissingCredentialError = require('../errors').MissingCredentialError

module.exports = class User

  constructor: (userResource, client, options) ->
    @client = -> client
    @resource = -> userResource


  wallets: (callback) ->
    return callback(null, @_wallets) if @_wallets
    
    resource = @resource().wallets

    wallets = new Wallets(resource, @client())
    
    wallets.loadCollection (error, wallets) =>
      return callback(error) if error

      @_wallets = wallets
      callback(null, @_wallets)

  # Note: requires user auth
  #       Should we remove this entirely?
  update: (properties, callback) ->
    @resource().update properties, (error, userResource) =>
      return callback(error) if error

      @_user = new User userResource, @client()
      callback null, @_user
