
module.exports = class Applications

  constructor: (client, applicationsResource) ->
    @client = -> client
    if applicationsResource?
      for app in applicationsResource
        @[app.name] = app


  create: (attributes, callback) -> 
    if @client()._developer?
      developerResource = @client()._developer.resource()
      developerResource.applications.create attributes, (error, app) =>
        return callback(error) if error

        # Updates @_applications with new app.
        # If @_applications hasn't been memoized then
        # it makes a call to the server
        if @client()._applications
          callback null, app
        else
          developerResource.applications.list (error, apps) =>
            return callback(error) if error
            
            @client()._applications = apps
            callback null, app
    else
      throw 'You must authenticate as a developer before creating and application'