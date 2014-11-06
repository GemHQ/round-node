
Developer = require './resources/developer'
Applications = require './resources/applications'

module.exports = class Client

  constructor: (patchboard) ->
    @patchboard = -> patchboard
    @resources = -> patchboard.resources
    
    # !!!! Shoudl we be passing something other than null????
    # is there a way to pass the default apps w/o making a call
    @applications = new Applications @, null

    @developers = {
        # 'credentials' requires email and pubkey
        # credentials can also take a privkey to authorize the client as a developer
        create: (credentials, callback) =>

          @resources().developers.create credentials, (error, developerResource) =>
              return callback(error) if error

              @_developer = new Developer(@, developerResource)

              if credentials.privkey
                @patchboard().context.authorize 'Gem-Developer', credentials
              
              callback null, @_developer
    }

    @developer = -> 
      return @_developer if @_developer

      throw 'You have not yet authenticated as a developer'


    @authenticate = (scheme, credentials, callback) ->
      @patchboard().context.authorize scheme, credentials

      if scheme is 'Gem-Developer'
        @resources().developers.get (error, developerResource) =>
          return callback(error) if error

          @_developer = new Developer(@, developerResource)
          callback null, @_developer








