
Application = require './application'

module.exports = class Applications

  constructor: (client, applicationsResource) ->
    @client = -> client
    if applicationsResource?
      for app in applicationsResource
        @[app.name] = new Application client, app


    @create = (attributes, callback) -> 
      if client._developer?
        developerResource = client._developer.resource()
        developerResource.applications.create attributes, (error, appResource) =>
          return callback(error) if error

          # Updates @_applications with new app.
          # If @_applications hasn't been memoized then
          # it makes a call to the server
          if client._applications
            # ????????? is this how we want to add apps?
            client._applications[appResource.name] = new Application client, appResource
            callback null, client._applications[appResource.name]
          else
            developerResource.applications.list (error, appsResource) =>
              return callback(error) if error
              
              client._applications = new Applications client, appsResource
              callback null, new Application client, appResource
      else
        throw 'You must authenticate as a developer before creating and application'