
Applications = require './applications'

module.exports = class Developer

  constructor: (client, resource) ->
    @client = -> client
    @resource = -> resource
    

  applications: (callback) ->
    return callback(null, @client()._applications) if @client()._applications
    
    applicationsResource = @resource().applications
    @resource().applications.list (error, applicationsArray) =>
      return callback(error) if error

      @client()._applications = new Applications @client(), applicationsResource, applicationsArray
      callback null, @client()._applications
    
  # Updates authenticated developer's credentials
  # with the provided credentials. Then autheticates
  # with the new credentials and returns a developer object
  update: (credentials, callback) ->
    @resource().update credentials, (error, developerResource) =>
      return callback(error) if error
      
      @client()._developer = new Developer(@client(), developerResource)
      @client().patchboard().context.authorize 'Gem-Developer', credentials

      callback null, @client()._developer
