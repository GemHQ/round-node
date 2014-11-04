
module.exports = class Client

  constructor: (@patchboard) ->
    @resources = @patchboard.resources

  developers: -> {
      # callback receives an error and a developer
      # credentials requires email and pubkey
      # credentials can also take a privkey to authorize
      # the client as a developer
      create: (credentials, callback) =>
        return callback(null, @_developer) if @_developer?

        @resources.developers.create credentials, (error, developer) =>
            return callback(error) if error

            @_developer = developer
            
            if credentials.privkey
              @patchboard.context.authorize 'Gem-Developer', credentials
              callback null, @_developer

  }

  developer: -> 

    updateDeveloper = (developerResource, credentials, callback) =>
      developerResource.update credentials, (error, developer) =>
        callback(error) if error

        @_developer = developer
        
        @patchboard.context.authorize 'Gem-Developer', credentials

        callback null, @_developer


    getDevApps = (developerResource, callback) =>
      developerResource.applications.list (error, applications) =>
        @_applications = applications
        callback(error) if error
        callback null, @_applications

    return {

      applications: (callback) =>
        return callback @_applications if @_applications

        if @_developer
          getDevApps @_developer, callback
        else
          @resources.developers.get (error, developer) =>
            @_developer = developer

            getDevApps @_developer, callback

      # Updates authenticated developer's credentials
      # with the provided credentials. Then autheticates
      # with the new credentials and returns a developer object
      update: (credentials, callback) =>
        if @_developer
          updateDeveloper @_developer, credentials, callback
        else
          @resources.developers.get (error, developer) =>
            callback(error) if error

            updateDeveloper developer, credentials, callback

    }

