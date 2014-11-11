
module.exports = class User

  constructor: (client, userResource) ->
    @client = -> client
    @userResource = -> userResource


  beginDeviceAuthorization: (name, device_id) ->
    @client().patchboard().context.schemes['GEM-OOB-OTP']['credential'] = 'data="none"'
    @currentDeviceName = name
    @currentDeviceId = device_id
    reply = @userResource().authorize_device {name, device_id}

    try
      # ????? WHATS HAPPENING HERE? 

  # credentials requires: app_url, api_token, key, secret
  completeDeviceAuthorization: (credentials) ->
    try
      @client().authenticateOTP credentials

      r = @userResource().authorize_device {name: @currentDeviceName, device_id: @currentDeviceId}
      


