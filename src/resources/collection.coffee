Application = require './application'

module.exports = class Collection

  # populates collection with wrapped resources
  getData = (callback) ->
    @resource().list (error, resourceArray) =>
      return callback(error) if error

      for resource in resourceArray
        wrappedResource = new @type(resource, @client())

        # FIXME:  it's inefficient to check name on every loop
                  # for every type of Collection
        if @type.name == 'Account'
          wrappedResource.wallet = @wallet

        # The key is a reference to the resource's name
        # therefor it will update when the resource updates.
        name = wrappedResource.resource().name or
               # name = string for addresses
               wrappedResource.resource().string
        @collection[name] = wrappedResource

      callback null, @


  constructor: (applicationsResource, client, callback) ->
    @client = -> client
    @resource = -> applicationsResource
    @collection = {}
    # calls like client.users do not need to fetch data
    # therefor they don't pass a callback
    getData.call(@, callback) if callback


  refresh: (callback) ->
    @collection = {}
    getData.call(@, callback)


  add: (key, model) ->
    @collection[key] = model