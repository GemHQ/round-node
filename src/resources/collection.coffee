Application = require './application'

module.exports = class Collection

  # # populates collection with wrapped resources
  # getData = (callback) ->
  #   @resource().list (error, resourceArray) =>
  #     return callback(error) if error

  #     for resource in resourceArray
  #       wrappedResource = new @type(resource, @client())

  #       # FIXME:  it's inefficient to check name on every loop
  #                 # for every type of Collection
  #       if @type.name == 'Account'
  #         wrappedResource.wallet = @wallet

  #       # The key is a reference to the resource's name
  #       # therefor it will update when the resource updates.
  #       name = wrappedResource.resource().name or
  #              # name = string for addresses
  #              wrappedResource.resource().string
  #       @collection[name] = wrappedResource

  #     callback null, @


  constructor: (applicationsResource, client, callback) ->
    @resource = -> applicationsResource
    @client = -> client
    @collection = {}


  loadCollection: (props, callback) ->
    # Makes props optional
    if arguments.length < 2 then callback = arguments[0]

    @resource().list (error, resourceArray) =>
      return callback(error) if error

      for resource in resourceArray
        wrappedResource = new @type(resource, @client(), props)

        key = resource[@key]

        @add(key, wrappedResource)

      callback(null, @)


  refresh: (callback) ->
    @collection = {}
    @loadCollection(callback)


  add: (key, model) ->
    @collection[key] = model