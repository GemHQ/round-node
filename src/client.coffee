
Developers = require './resources/developers'
Developer = require './resources/developer'
Applications = require './resources/applications'
Users = require './resources/users'
User = require './resources/user'
Account = require './resources/account'
Wallet = require './resources/wallet'
errors = require('./errors')

module.exports = class Client

  constructor: (patchboard) ->
    @patchboard = -> patchboard
    @resources = -> patchboard.resources
    
    @developers = new Developers(@resources().developers, @)

    # Fix: throw a real error and change relevant tests
    @developer = ->
      return @_developer if @_developer

      throw Error 'You have not yet authenticated as a developer'

    @users = new Users(@resources().users, @)

    # FIX: should recieve a url. Use python and ruby are very
    # different in their implentations of this
    @user = (callback) ->
      return callback(null, @_user) if @_user
      
      user_url = @patchboard().context.user_url
      @resources().user(user_url).get (error, userResource) =>
        return callback(error) if error

        @_user = new User(userResource, @)
        callback null, @_user

    # QUESTION: Why doesn't this need to make a call to the database?
    # QUESTION: shouldn't this method solely live on the wallet? 
    #   What's the benefit of having it on the client
    @account = (url) ->
      if url
        accountResource = @resources().accounts(url)
        new Account(accountResource, @)
      else
        throw "Error: must provide the URL of the account your looking for"


    @wallet = (url, callback) ->
      @resources().wallet(url).get (error, walletResource) ->
        return callback(error) if error
        
        wallet = new Wallet(walletResource, @)
        callback null, wallet


    @authenticate = (scheme, credentials, callback) ->
      @patchboard().context.authorize scheme, credentials
      
      if scheme is 'Gem-Developer'
        @resources().developers.get (error, developerResource) =>
          return callback(error) if error

          @_developer = new Developer(developerResource, @)
          callback null, @_developer


    @authenticateDeveloper = (credentials, callback) ->
      requiredCredentials = ['email', 'pubkey', 'privkey']

      for credential in requiredCredentials
        if credential not of credentials
          return callback errors.MissingCredentialError(credential)

      @patchboard().context.authorize 'Gem-Developer', credentials

      @resources().developers.get (error, developerResource) =>
        return callback(error) if error

        @_developer = new Developer(developerResource, @)
        callback null, @_developer


    # Credentials requires api_token, key, secret
    # Credentials takes 'override', as an optional property
    @authenticateOTP = (credentials) ->
      credentials.override = credentials.override || true

      if 'credential' of @patchboard().context.schemes['Gem-OOB-OTP']
        if credentials.override is false
          throw errors.ExistingAuthenticationError
      
      @patchboard().context.authorize 'Gem-OOB-OTP', credentials
      return true


    # Credentials requires api_tokne, user_url, user_token, device_id
    # Optional credentials are: app_url, override, fetch
    @authenticateDevice = (credentials, callback) ->
      credentials.override = credentials.override || false
      credentials.fetch = credentials.fetch || true

      deviceScheme = @patchboard().context.schemes['Gem-Device']
      if 'credentials' of deviceScheme and !credentials.override
        return callback new Error('This object already has Gem-Device authentication. To overwrite it call authenticate_device with override=true.')

      @patchboard().context.authorize 'Gem-Device', credentials
      # ????? SHOULD I MEMOIZE THE USER ?????
      if credentials.fetch
        @user (error, user) ->
          callback(error, user)
      else
        callback(null, true)


    # Required credentials are app_url, api_token, instance_id
    @authenticateApplication = (credentials, callback) ->
      credentials.override = credentials.override || false
      credentials.fetch = credentials.fetch || true

      applicationScheme = @patchboard().context.schemes['Gem-Application']
      if 'credential' of applicationScheme and !credentials.override
        return callback errors.ExistingAuthenticationError

      @patchboard.context.authorize 'Gem-Application', credentials


    # Credentials requires name, device_id, email, api_token, name (device)
    @beginDeviceAuthorization = (credentials, callback) ->
      {name, device_id, email, api_token} = credentials
      @authenticateOTP({api_token})
      
      resource = @resources().user_query({email})
      resource.authorize_device {name, device_id}, (error) ->
        responseHeader = error.response.headers['www-authenticate']
        regx = /key="(.*)"/
        matches = regx.exec responseHeader
        # debugger
        if matches
          key = matches[1]
          callback(null, key)
        else
          callback(error)


    # credentials requires: app_url, api_token, key, secret, name (of device), device_id 
    @completeDeviceAuthorization = (credentials, callback) ->
      @authenticateOTP(credentials)

      {name, device_id, email} = credentials
      authorizeDeviceCreds = {name, device_id}
      
      resource = @resources().user_query({email})
      resource.authorize_device authorizeDeviceCreds, (error, userResource) =>
        return callback(error) if error

        @authenticateDevice {
          app_url: credentials.app_url
          api_token: credentials.api_token
          user_url: userResource.url
          user_token: userResource.user_token
          device_id: credentials.device_id
          }, (error, user) ->
            return callback(error) if error

            callback null, user















