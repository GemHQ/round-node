
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
      

  developers: ->
    {
      # callback takes an error and a developer
      # credentials requires email and pubkey
      # credentials can also take a privkey to authorize
      # the client as a developer
      create: (credentials, callback) =>
        @resources.developers.create credentials, (error, developer) =>
          unless @_developer?
            callback error if erro  r
            # !!! this is being set on create. Should it be set on authorize instead? !!!
            # !!! why do we memoize this? How about if they want to create a 2nd dev !!!
            @_developer = developer
            if credentials.privkey
              @patchboard.context.authorize 'Gem-Developer', credentials

          callback null, @_developer

    }









