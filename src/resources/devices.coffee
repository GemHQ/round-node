Promise = require('bluebird')
{promisify} = Promise

module.exports = class Devices

  constructor: ({resource, client}) ->
    @resource = resource
    @client = client


  create: ({name, redirect_uri}) ->
    params = {name}
    params.redirect_uri = redirect_uri if redirect_uri
    @resource.create = promisify(@resource.create)
    @resource.create(params)
    .then (authRequestResource) ->
      {
        device_token: authRequestResource.metadata.device_token,
        mfa_uri: authRequestResource.mfa_uri
      }
    .catch (error) -> throw new Error(error)
      