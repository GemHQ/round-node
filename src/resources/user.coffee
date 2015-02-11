
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


  # content can take an email, first_name, or last_name
  update: (content, callback) ->
    @resource().update content, (error, userResource) =>
      return callback(error) if error

      @_user = new User userResource, @client()
      callback null, @_user
