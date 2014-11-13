
Wallets = require './wallets'

module.exports = class User

  constructor: (client, userResource) ->
    @client = -> client
    @resource = -> userResource


  wallets: () ->
    return @_wallets if @_wallets

    walletsResource = @resource().wallets
    @_wallets = new Wallets @client(), walletsResource

  

  beginDeviceAuthorization: (credentials, callback) ->
    requiredCredentials = ['name', 'device_id']

    for credential in requiredCredentials
        if credential not of credentials
          throw "You must provide #{credential} in order to authenticate"

    {name, device_id} = credentials
    @client().patchboard().context.schemes['Gem-OOB-OTP']['credentials'] = 'data="none"'
    # ????? WHEN DO WE USE: @currentDeviceName
    @currentDeviceName = name
    @currentDeviceId = device_id
    @resource().authorize_device {name, device_id}, (error) ->
      responseHeader = error.response.headers['www-authenticate']
      regx = /key="(.*)"/
      matches = regx.exec responseHeader
      if matches
        key = matches[1]
        callback key
      else
        throw error

  # credentials requires: app_url, api_token, key, secret
  completeDeviceAuthorization: (credentials, callback) ->
    requiredCredentials = ['app_url', 'api_token', 'key', 'secret']

    for credential in requiredCredentials
        if credential not of credentials
          throw "You must provide #{credential} in order to authenticate"
    
    @client().authenticateOTP credentials

    authorizeDeviceCreds = {name: @currentDeviceName, device_id: @currentDeviceId}
    @resource().authorize_device authorizeDeviceCreds, (error, user) =>

      @client().authenticateDevice {
        app_url: credentials.app_url
        api_token: credentials.api_token
        user_url: user.url
        user_token: user.user_token
        device_id: @currentDeviceId
        }, (error, user) ->
          return callback(error) if error

          callback null, new User @client(), user
