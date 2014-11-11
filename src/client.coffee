
Developers = require './resources/developers'
Developer = require './resources/developer'
Applications = require './resources/applications'
Users = require './resources/users'
User = require './resources/user'

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

    @user = (callback) ->
      return callback(null, @_user) if @_user

      @resources().user(@patchboard().context.user_url).get (error, userResource) =>
        # !!!!! THROW MORE DESCRIPTIVE ERROR RATHER THAN PATCBOARD ERROR
        return callback(error) if error

        @_user = new User(@, userResource)
        callback null, @_user


    @authenticate = (scheme, credentials, callback) ->
      @patchboard().context.authorize scheme, credentials

      if scheme is 'Gem-Developer'
        @resources().developers.get (error, developerResource) =>
          return callback(error) if error

          @_developer = new Developer(@, developerResource)
          callback null, @_developer

    # credentials requires: apiToken, userUrl, userToken, deviceId
    # optional params are: app_url, override, fetch
    @authenticateDevice = (credentials, callback) ->
      requiredCredentials = ['api_token', 'user_url', 'user_token', 'device_id']
      credentials.override = credentials.override || false
      credentials.fetch = credentials.fetch || true

      if 'credentials' of patchboard.context.schemes['Gem-Device'] and !credentials.override
        return callback 'This object already has Gem-Device authentication. To overwrite it call authenticateDevice with override=true.'
      
      for credential in requiredCredentials
        if credential not of credentials
          return callback "You must provide #{credential} in order to authenticate a device"

      @patchboard().context.authorize 'Gem-Device', credentials

      if credentials.fetch
        @user (error, user) ->
          return callback error if error
          callback null, user
      else
        callback null, true









