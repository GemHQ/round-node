
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
    # Save and remove privkey because the update call
    # can't receive the privkey. However the privkey is still
    # needed to reauthorize with the new credentials. 
    {privkey} = credentials 
    delete credentials.privkey if credentials.privkey

    @resource().update credentials, (error, developerResource) =>
      return callback(error) if error
      
      @resource = -> developerResource

      credentials.privkey = privkey
      @client().patchboard().context.authorize 'Gem-Developer', credentials

      callback null, @
