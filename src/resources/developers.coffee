
Developer = require './developer'
# helpers = require('../helpers')
MissingCredentialError = require('../errors').MissingCredentialError

module.exports = class Developers

  constructor: (resource, client) ->
    @client = -> client
    @resource = -> resource
    
  # credentials can also take a privkey to authorize the client as a developer
  create: (credentials, callback) ->
    requiredCredentials = ['email', 'pubkey']
    
    for credential in requiredCredentials
      if credential not of credentials
        return callback(MissingCredentialError(credential), credential)

    @resource().create credentials, (error, developerResource) =>
      return callback(error) if error

      @client()._developer = new Developer(developerResource, @client())

      if credentials.privkey
        @client().patchboard().context.authorize 'Gem-Developer', credentials
      
      callback null, @client()._developer