Application = require './application'

module.exports = class Collection

  _isNumber = (n) ->
    !isNaN(parseFloat(n)) && isFinite(n)


  constructor: (applicationsResource, client, callback) ->
    @resource = -> applicationsResource
    @client = -> client
    @_collection = null
    @_modelList = null


  loadCollection: (props, callback) ->
    # Makes props optional
    if arguments.length == 1
      callback = arguments[0]
      props = {}

    @resource().list (error, resourceArray) =>
      return callback(error) if error
      
      @_modelList = resourceArray.map (resource) =>
        new @type(resource, @client(), props)
      
      if @key
        @_collection = {}
        
        for resource in resourceArray
          wrappedResource = new @type(resource, @client(), props)

          key = resource[@key]

          @add(key, wrappedResource)

      callback(null, @)


  refresh: (callback) ->
    @loadCollection(callback)


  add: (key, model) ->
    if @_collection?
      @_collection[key] = model
    
    @_modelList.push(model)


  get: (key) ->
    # Return entire collection if no key is provided
    return @_modelList unless key

    if _isNumber(key)
      model = @_modelList[key]
    else
      model = @_collection[key]

    if model?
      return model
    else
      throw new Error "No object in the #{@type.name}s collection
                      for that value."


  getAll: ->
    @_modelList




