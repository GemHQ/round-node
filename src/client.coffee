
Developers = require './resources/developers'
Developer = require './resources/developer'
Applications = require './resources/applications'
Users = require './resources/users'

module.exports = class Client

  constructor: (patchboard) ->
    # !!!!! Do users need access to patchboard and resources?
    @patchboard = -> patchboard
    @resources = -> patchboard.resources
    
    # !!!! Should we be passing something other than null????
    # !!!! Should we fetch the applications resource here? 
    # is there a way to pass the default apps w/o making a call
    # if a user authorizes as a developer but does not run developer.applications
    # then the client is not able to access the appplications without making a call
    @applications = @_applications || new Applications @, null


    @developers = new Developers(@)

    @developer = -> 
      return @_developer if @_developer

      throw 'You have not yet authenticated as a developer'


    @users = new Users(@)

    @authenticate = (scheme, credentials, callback) ->
      @patchboard().context.authorize scheme, credentials

      if scheme is 'Gem-Developer'
        @resources().developers.get (error, developerResource) =>
          return callback(error) if error

          @_developer = new Developer(@, developerResource)
          callback null, @_developer