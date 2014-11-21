
Application = require './application'
Collection = require './collection'
errors = require '../errors'

module.exports = class Applications extends Collection

  # Note: type is used in Collection
  type: Application

  # constructor: (applicationsResource, client, callback) ->
  #   @type = Application
  #   @client = -> client
  #   @resource = -> applicationsResource
    # @collection = {}

    # applicationsResource.list (error, applications) =>
    #   return callback(error) if error

    #   for app in applications
    #     @collection[app.name] = new Application app, client

    #   callback null, @


  create: (content, callback) ->
    @resource().create content, (error, appResource) =>
      return callback(error) if error

      application = new Application appResource, @client()
      @collection[appResource.name] = application
      
      callback null, application


