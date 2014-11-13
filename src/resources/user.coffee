
module.exports = class User

  constructor: (client, userResource) ->
    @client = -> client
    @resource = -> userResource


  beginDeviceAuthorization: (credentials, callback) ->
    requiredCredentials = ['name', 'device_id']

    for credential in requiredCredentials
        if credential not of credentials
          throw "You must provide #{credential} in order to authenticate"

    @client().patchboard().context.schemes['GEM-OOB-OTP']['credentials'] = 'data="none"'
    @currentDeviceName = credentials.name
    @currentDeviceId = credentials.device_id
    @resource().authorize_device {name, device_id}, (error, data) ->
      responseHeader = error.response.headers['www-authenticate']
      matches = regx.exec responseHeader
      if matches
        regx = /key="(.*)"/
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

    @resource().authorize_device {name: @currentDeviceName, device_id: @currentDeviceId}, (error, user) =>

      @client().authenticateDevice( {
        app_url: credentials.app_url
        api_token: credentials.api_token
        user_url: user.url
        # !!! MAKE SURE USER.USER_TOKEN IS VALID
        user_token: user.user_token
        device_id: @currentDeviceId
        }, (error, user) ->
          return callback(error) if error

          callback null, new User @client(), user
      )
