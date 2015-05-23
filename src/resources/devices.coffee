
module.exports = class Devices

  constructor: ({resource, client}) ->
    @resource = resource
    @client = client


  create: ({name: redirect_uri}, callback) ->
    @resource.create arguments[0], (error, authRequestResource) ->
      return callback(error) if error

      callback(null, {
        device_token: authRequestResource.metadata.device_token,
        mfa_uri: authRequestResource.mfa_uri
      })
      