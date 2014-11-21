
Applications = require './applications'

module.exports = class Developer

  constructor: (resource, client) ->
    @client = -> client
    @resource = -> resource
    
  
  applications: (callback) ->
    return callback(null, @_applications) if @_applications

    applicationsResource = @resource().applications

    new Applications applicationsResource, @client(), (error, applications) =>
      return callback(error) if error

      @_applications = applications
      callback null, @_applications


  # Updates authenticated developer's credentials
  # with the provided credentials. Then autheticates
  # with the new credentials and returns the developer object
  update: (credentials, callback) ->
    @resource().update credentials, (error, developerResource) =>
      return callback(error) if error
      
      @resource = -> developerResource
      @client().patchboard().context.authorize 'Gem-Developer', credentials

      callback null, @
