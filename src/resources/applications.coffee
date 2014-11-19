
Application = require './application'

module.exports = class Applications

  constructor: (client, applicationsResource, applicationsArray) ->
    @client = -> client
    @resource = -> applicationsResource
    if applicationsArray?
      for app in applicationsArray
        @[app.name] = new Application client, app

  create: (content, callback) ->
    @resource().create content, (error, appResource) =>
      return callback(error) if error

      application = new Application @client(), appResource
      @[appResource.name] = application
      
      callback null, application
