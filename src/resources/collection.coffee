Application = require './application'


module.exports = class Collection

  getData = (callback) ->
    @resource().list (error, items) =>
      return callback(error) if error

      for item in items
        @collection[item.name] = new @type(item, @client())

      callback null, @


  constructor: (applicationsResource, client, callback) ->
    @client = -> client
    @resource = -> applicationsResource
    @collection = {}
    
    getData.call(@, callback)


  refresh: (callback) ->
    @collection = {}
    getData.call(@, callback)