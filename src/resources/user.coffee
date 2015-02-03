
Wallets = require './wallets'
MissingCredentialError = require('../errors').MissingCredentialError

module.exports = class User

  constructor: (userResource, client) ->
    @client = -> client
    @resource = -> userResource


  wallets: (callback) ->
    return callback(null, @_wallets) if @_wallets

    walletsResource = @resource().wallets
    new Wallets walletsResource, @client(), (error, wallets) =>
      return callback(error) if error

      @_wallets = wallets
      callback null, @_wallets

  # Note: requires user auth
  #       Should we remove this entirely?
  update: (properties, callback) ->
    @resource().update properties, (error, userResource) =>
      return callback(error) if error

      @_user = new User userResource, @client()
      callback null, @_user


  # FixMe: move to client
  # Credentials requires name, device_id, email, api_token
  beginDeviceAuthorization: (credentials, callback) ->
    {name, device_id, email, api_token} = credentials
    @client().authenticateOTP({api_token})
    # @client().patchboard().context.schemes['Gem-OOB-OTP']['credentials'] = 'data="none"'
    @currentDeviceName = name
    @currentDeviceId = device_id
    
    resource = @client().resources().user_query({email})
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


  # FixMe: move to client
  # credentials requires: app_url, api_token, key, secret
  completeDeviceAuthorization: (credentials, callback) ->
    @client().authenticateOTP credentials

    authorizeDeviceCreds = {name: @currentDeviceName, device_id: @currentDeviceId}
    resource = @client().resources().user_query({email})
    resource.authorize_device authorizeDeviceCreds, (error, user) =>

      @client().authenticateDevice {
        app_url: credentials.app_url
        api_token: credentials.api_token
        user_url: user.url
        user_token: user.user_token
        device_id: @currentDeviceId
        }, (error, user) ->
          return callback(error) if error

          callback null, new User user, @client()
