
Developers = require './resources/developers'
Developer = require './resources/developer'
Application = require './resources/application'
Applications = require './resources/applications'
Users = require './resources/users'
User = require './resources/user'
Account = require './resources/account'
Wallet = require './resources/wallet'

module.exports = class Client

  constructor: (patchboard, network) ->
    @network = network
    @patchboard = -> patchboard
    @resources = -> patchboard.resources


    @developers = new Developers(@resources().developers, @)


    @developer = ->
      return @_developer if @_developer

      throw new Error('You have not yet authenticated as a developer')


    @users = new Users(@resources().users, @)


    # content requires an email or user_url
    @user = (content, callback) ->
      {email, user_url} = content

      if email?
        resource = @resources().user_query({email})
      else
        resource = @resources().user(user_url)

      resource.get (error, userResource) =>
        callback(error, new User(userResource, @))


    @application = ->
      return @_application if @_application

      throw new Error('You have not yet authenticated an application')


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


    # Credentials requires email and privkey
    @authenticateDeveloper = (credentials, callback) ->
      @patchboard().context.authorize 'Gem-Developer', credentials

      @resources().developers.get (error, resource) =>
        return callback(error) if error

        @_developer = new Developer(resource, @)
        callback null, @_developer


    # Credentials requires api_token, key, secret
    # Credentials takes 'override', as an optional property
    @authenticateOTP = (credentials) ->
      credentials.override = credentials.override || true

      if 'credential' of @patchboard().context.schemes['Gem-OOB-OTP']
        if credentials.override is false
          throw new Error "This object is already authenticated.
                          To override the authentication, provide
                          the property: 'override: true'"

      @patchboard().context.authorize 'Gem-OOB-OTP', credentials
      return true


    # Credentials requires api_token, instance_id, app_url
    # Credentials takes override as an optional property
    @authenticateApplication = (credentials, callback) ->
      {app_url, api_token, instance_id} = credentials
      if !api_token or !instance_id or !app_url
        return callback(new Error("api_token, instance_id, and app_url are required"))

      credentials.override  ||= false

      applicationScheme = @patchboard().context.schemes['Gem-Application']
      if 'credential' of applicationScheme and !credentials.override
        return callback(new Error("This object is already authenticated. To override the authentication, provide the property: 'override: true"))

      @patchboard().context.authorize 'Gem-Application', credentials

      @resources().application(app_url).get (error, resource) =>
        return callback(error) if error

        @_application = new Application(resource, @)
        callback(null, @_application)


    # Credentials requires api_token, user_token, device_id, [user_url or email]
    # Optional credentials are: override, fetch
    @authenticateDevice = (credentials, callback) ->
      credentials.override ||= false
      credentials.fetch ||= true

      deviceScheme = @patchboard().context.schemes['Gem-Device']
      if 'credentials' of deviceScheme and !credentials.override
        return callback new Error('This object already has Gem-Device authentication. To overwrite it call authenticate_device with override=true.')

      @patchboard().context.authorize 'Gem-Device', credentials

      if credentials.fetch
        {email, user_url} = credentials
        @user {email, user_url}, (error, user) ->
          callback(error, user)
      else
        callback(null, true)


    # Credentials requires device_id, email, api_token, name (device)
    @beginDeviceAuthorization = (credentials, callback) ->
      {name, device_id, email, api_token} = credentials
      @authenticateOTP({api_token})

      resource = @resources().user_query({email})
      resource.authorize_device {name, device_id}, (error) ->
        responseHeader = error.response.headers['www-authenticate']
        regx = /key="(.*)"/
        matches = regx.exec responseHeader
        if matches
          key = matches[1]
          callback(null, key)
        else
          callback(error)


    # credentials requires: api_token, key, secret, name (of device), device_id, email
    @completeDeviceAuthorization = (credentials, callback) ->
      @authenticateOTP(credentials)

      {name, device_id, email} = credentials

      resource = @resources().user_query({email})
      resource.authorize_device {name, device_id}, (error, userResource) =>
        return callback(error) if error

        @authenticateDevice {
          api_token: credentials.api_token
          user_url: userResource.url
          user_token: userResource.user_token
          device_id: credentials.device_id
          }, (error, user) ->
            callback(error, user)
