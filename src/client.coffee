
module.exports = class Client

  constructor: (@patchboard) ->
    @resources = @patchboard.resources


  developer: (callback) -> 
    console.log @
    callback @_developer if @_developer
    
    @resources.developers.get (error, developer) =>
      callback error if error

      @_developer = developer
      callback null, @_developer
      

  developers: -> {
      # callback takes an error and a developer
      # credentials requires email and pubkey
      # credentials can also take a privkey to authorize
      # the client as a developer
      create: (credentials, callback) =>
        return callback(null, @_developer) if @_developer?

        @resources.developers.create credentials, (error, developer) =>
            return callback(error) if error
            # !!! why do we memoize this? How about if they want to create a 2nd dev !!!
            @_developer = developer
            
            if credentials.privkey
              @patchboard.context.authorize 'Gem-Developer', credentials
              callback null, @_developer

    }

  developer: -> {

    applications: (callback) =>
      return callback @_applications if @_applications

      if @_developer
        @getDevApps @_developer, callback
      else
        @resources.developers.get (error, developer) =>
          @_developer = developer

          @getDevApps @_developer, callback

  }

  getDevApps: (developerResource, callback) ->
    developerResource.applications.list (error, applications) =>
      @_applications = applications
      callback(error) if error
      callback null, @_applications




    
    # if not @_developer?
    #   @resources.developers.get (err, developer) ->
    #     throw err if err

    #     @_developer = developer



