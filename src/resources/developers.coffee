
Developer = require './developer'
MissingCredentialError = require('../errors').MissingCredentialError

# Developers does not inherit from Coolection
# because the developer resource does not have .list method
module.exports = class Developers
  
  constructor: (resource, client) ->
    @client = -> client
    @resource = -> resource
  

  # Credentials requires email and pubkey
  # It can also take a privkey to authorize the client as a developer
  create: (credentials, callback) ->
    @resource().create credentials, (error, developerResource) =>
      return callback(error) if error

      @client()._developer = new Developer(developerResource, @client())

      if credentials.privkey
        @client().patchboard().context.authorize 'Gem-Developer', credentials
      
      callback null, @client()._developer