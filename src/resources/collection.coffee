Application = require './application'


module.exports = class Collection

  # populates collection with wrapped resources
  getData = (callback) ->
    @resource().list (error, resourceArray) =>
      return callback(error) if error

      for resource in resourceArray
        wrappedResource = new @type(resource, @client())
        # The key is a reference to the resource's name
        # therefor it will update when the resource updates. 
        @collection[wrappedResource.resource().name] = wrappedResource

      callback null, @


  constructor: (applicationsResource, client, callback) ->
    @client = -> client
    @resource = -> applicationsResource
    @collection = {}
    
    getData.call(@, callback) if callback


  refresh: (callback) ->
    @collection = {}
    getData.call(@, callback)