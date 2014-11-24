
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
    
    # FIX: should be async
    @developers = new Developers(@resources().developers, @)

    # Fix: through a real error
    @developer = ->
      return @_developer if @_developer

      throw 'You have not yet authenticated as a developer'


    @users = new Users(@resources().users, @)

    # FIX: should recieve a url. Use python and ruby are very
    # different in their implentation of this
    @user = (callback) ->
      return callback(null, @_user) if @_user
      
      user_url = @patchboard().context.user_url
      @resources().user(user_url).get (error, userResource) =>
        return callback(error) if error

        @_user = new User(userResource, @)
        callback null, @_user

    # QUESTION: Why doesnt this need to make a call to the database?
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


    # takes 'override', as an optional property
    @authenticateOTP = (credentials) ->
      requiredCredentials = ['api_token', 'key', 'secret']
      credentials.override = credentials.override || true

      for credential in requiredCredentials
        if credential not of credentials
          return callback errors.MissingCredentialError(credential)

      if 'credential' of @patchboard().context.schemes['Gem-OOB-OTP']
        if credentials.override is false
          throw errors.ExistingAuthenticationError
      
      @patchboard().context.authorize 'Gem-OOB-OTP', credentials
      return true


    # optional credentials are: app_url, override, fetch
    @authenticateDevice = (credentials, callback) ->
      requiredCredentials = ['api_token', 'user_url', 'user_token', 'device_id']
      credentials.override = credentials.override || false
      credentials.fetch = credentials.fetch || true

      deviceScheme = @patchboard().context.schemes['Gem-Device']
      if 'credentials' of deviceScheme and !credentials.override
        return callback errors.ExistingAuthenticationError
      
      for credential in requiredCredentials
        if credential not of credentials
          return callback errors.MissingCredentialError(credential)

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
        return callback errors.ExistingAuthenticationError

      for credential in requiredCredentials
        if credential not of credentials
          return callback errors.MissingCredentialError(credential)

      @patchboard.context.authorize 'Gem-Application', credentials

