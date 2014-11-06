
Developer = require './resources/developer'


module.exports = class Client

  constructor: (@patchboard) ->
    @resources = @patchboard.resources
    
    @applications = {

      create: (attributes, callback) => 
          if @_developer?
            developerResource = @_developer.resource
            developerResource.applications.create attributes, (error, app) =>
              return callback(error) if error

              # Updates @_applications with new app.
              # If @_applications hasn't been memoized then
              # it makes a call to the server
              if @_applications
                callback null, app
              else
                developerResource.applications.list (error, apps) =>
                  return callback(error) if error
                  
                  @_applications = apps
                  callback null, app
          else
            throw 'You must authenticate as a developer before creating and application'
    }

  developers: -> {
      # 'credentials' requires email and pubkey
      # credentials can also take a privkey to authorize the client as a developer
      create: (credentials, callback) =>

        @resources.developers.create credentials, (error, developerResource) =>
            return callback(error) if error

            @_developer = new Developer(@, developerResource)

            if credentials.privkey
              @patchboard.context.authorize 'Gem-Developer', credentials
            
            callback null, @_developer
  }

  developer: -> 
    return @_developer if @_developer

    throw 'You have not yet authenticated as a developer'


  # applications: ((client)-> new Applications client)(@)

  authenticate: (scheme, credentials, callback) ->
    @patchboard.context.authorize scheme, credentials

    if scheme is 'Gem-Developer'
      @resources.developers.get (error, developerResource) =>
        return callback(error) if error

        @_developer = new Developer(@, developerResource)
        callback null, @_developer








