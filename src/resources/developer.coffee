
clone = require 'clone'
Applications = require './applications'

module.exports = class Developer

  constructor: (resource, client, options) ->
    @client = -> client
    @resource = -> resource
    
  
  applications: (callback) ->
    return callback(null, @_applications) if @_applications

    resource = @resource().applications

    applications = new Applications(resource, @client())
    
    applications.loadCollection (error, applications) =>
      return callback(error) if error

      @_applications = applications
      callback(null, @_applications)


  update: (credentials, callback) ->
    updateCreds = clone(credentials, false)
    delete updateCreds.privkey if updateCreds.privkey

    @resource().update updateCreds, (error, developerResource) =>
      return callback(error) if error
      
      @resource = -> developerResource
      @client().patchboard().context.authorize 'Gem-Developer', credentials

      callback null, @
