
Application = require './application'
Collection = require './collection'
errors = require '../errors'

module.exports = class Applications extends Collection

  # Note: type is used in Collection
  type: Application


  create: (content, callback) ->
    @resource().create content, (error, appResource) =>
      return callback(error) if error

      application = new Application appResource, @client()
      # the key is a reference to the resource's name
      # therefor it will update when the resource updates. 
      @collection[application.resource().name] = application
      callback null, application


