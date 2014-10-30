
module.exports = class Client

  constructor: (@api) ->
    @resources = @api.resources



  developer: -> 
    {
      # callback receives an error and a developer
      # credentials requires email and pubkey
      # credentials can also take a privkey to authorize
      # the client as a developer
      create: (credentials, callback) =>
        @resources.developers.create credentials, (error, developer) ->
          unless @_developer?
            callback error if error
            @_developer = developer
            if credentials.privkey
              @resources.context.authorize 

          callback null, @_developer

    }









