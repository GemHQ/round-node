Application = require './application'

module.exports = class Collection

  constructor: (applicationsResource, client, callback) ->
    @resource = -> applicationsResource
    @client = -> client
    @collection = {}


  loadCollection: (props, callback) ->
    # Makes props optional
    if arguments.length == 1
      callback = arguments[0]
      props = {}

    @resource().list (error, resourceArray) =>
      return callback(error) if error
      
      for resource in resourceArray
        wrappedResource = new @type(resource, @client(), props)

        key = resource[@key]

        @add(key, wrappedResource)

      callback(null, @)


  refresh: (callback) ->
    @loadCollection(callback)


  add: (key, model) ->
    @collection[key] = model


  get: (key) ->
    # Return entire collection if no key is provided
    return @collection unless key

    model = @collection[key]

    if model?
      return model
    else
      throw new Error "No object in the #{@type.name}s collection
                      for that key. Provide the #{@key} of the
                      #{@type.name} you are looking for."






