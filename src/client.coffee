
Developers = require './resources/developers'
Developer = require './resources/developer'
Applications = require './resources/applications'
Users = require './resources/users'
User = require './resources/user'
Account = require './resources/account'
Wallet = require './resources/wallet'

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
    @applications = @_applications || new Applications @, @resources().application, null

    @developers = new Developers(@, @resources().developers)

    @developer = ->
      return @_developer if @_developer

      throw 'You have not yet authenticated as a developer'


    @users = new Users(@, @resources().users)

    @user = (callback) ->
      return callback(null, @_user) if @_user
      @resources().user(@patchboard().context.user_url).get (error, userResource) =>
        # !!!!! THROW MORE DESCRIPTIVE ERROR RATHER THAN PATCBOARD ERROR
        return callback(error) if error

        @_user = new User(@, userResource)
        callback null, @_user

    @account = (url) ->
      accountResource = @.resources().accounts(url)
      new Account(@, accountResource)

    @wallet = (url, callback) ->
      @resources().wallet(url).get (error, walletResource) ->
        return callback(error) if error
        
        wallet = new Wallet @, walletResource
        callback null, wallet

    @authenticate = (scheme, credentials, callback) ->
      @patchboard().context.authorize scheme, credentials
      
      if scheme is 'Gem-Developer'
        @resources().developers.get (error, developerResource) =>
          return callback(error) if error

          @_developer = new Developer(@, developerResource)
          callback null, @_developer

    @authenticateDeveloper = (credentials, callback) ->
      requiredCredentials = ['email', 'pubkey', 'privkey']
      # return error if missing a required credential
      for credential in requiredCredentials
        if credential not of credentials
          return callback "You must provide #{credential} in order
                          to authenticate a developer"

      @patchboard().context.authorize 'Gem-Developer', credentials

      @resources().developers.get (error, developerResource) =>
        return callback(error) if error

        @_developer = new Developer(@, developerResource)
        callback null, @_developer

    # takes 'override', as an optional property
    @authenticateOTP = (credentials) ->
      requiredCredentials = ['api_token', 'key', 'secret']
      credentials.override = credentials.override || true

      for credential in requiredCredentials
        if credential not of credentials
          throw "You must provide #{credential} in order to authenticate"

      if 'credential' of @patchboard().context.schemes['Gem-OOB-OTP']
        if credentials.override is false
          # !!!!! IS THIS THE RIGHT ERROR TO THROW !!!!!
          throw "This object already has Gem-Device authentication.
                To overwrite it call authenticate_device with override: true."
      
      @patchboard().context.authorize 'Gem-OOB-OTP', credentials
      return true 


    # optional credentials are: app_url, override, fetch
    @authenticateDevice = (credentials, callback) ->
      requiredCredentials = ['api_token', 'user_url', 'user_token', 'device_id']
      credentials.override = credentials.override || false
      credentials.fetch = credentials.fetch || true

      deviceScheme = @patchboard().context.schemes['Gem-Device']
      if 'credentials' of deviceScheme and !credentials.override
        return callback "This object already has Gem-Device authentication.
                        To overwrite it call authenticateDevice with
                        override: true."
      
      for credential in requiredCredentials
        if credential not of credentials
          return callback "You must provide #{credential} in order to
                          authenticate a device"

      @patchboard().context.authorize 'Gem-Device', credentials
      # ????? SHOULD I MEMOIZE THE USER ?????
      if credentials.fetch
        @user (error, user) ->
          return callback error if error
          callback null, user
      else
        callback null, true


    @authenticateApplication = (credentials, callback) ->
      requiredCredentials = ['app_url', 'api_token', 'instance_id']
      credentials.override = credentials.override || false
      credentials.fetch = credentials.fetch || true

      applicationScheme = @patchboard().context.schemes['Gem-Application']
      if 'credential' of applicationScheme and !credentials.override
        return callback "This object already has Gem-Application authentication.
                        To overwrite it call authenticateApplication with
                        override: true."

      for credential in requiredCredentials
        if credential not of credentials
          return callback "You must provide #{credential} in order to
                          authenticate as application"

      @patchboard.context.authorize 'Gem-Application', credentials

