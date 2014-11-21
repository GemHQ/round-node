Application = require './application'

module.exports = class Collection

  constructor: (applicationsResource, client, callback) ->
    # @type = Application
    @client = -> client
    @resource = -> applicationsResource
    @collection = {}
    
    @resource().list (error, items) =>
      return callback(error) if error

      for item in items
        @collection[item.name] = new @type(item, @client())

      callback null, @


  refresh: (callback) ->
    @collection = {}
    @resource().list (error, applications) =>
      return callback(error) if error

      for app in applications
        @collection[app.name] = new Application app, @client()

      callback null, @