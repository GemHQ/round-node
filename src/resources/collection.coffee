Application = require './application'

module.exports = class Collection

  _isNumber = (n) ->
    !isNaN(parseFloat(n)) && isFinite(n)


  constructor: (applicationsResource, client, callback) ->
    @resource = -> applicationsResource
    @client = -> client
    # an arry of models is populated for all resource types
    @_list = null
    # a hash table is populated if the model provides a key
    # ex: Accounts has a key property of 'name'
    @_hash = null


  loadCollection: (props, callback) ->
    # Makes props optional
    # Props is only used in cases where a collection needs
    # additional info at initialization time.
    # ex: when calling wallet.accounts you need to pass the wallet
    # so that all of the accounts can be created with a refrence to
    # the wallet that they belong to.
    if arguments.length == 1
      callback = arguments[0]
      props = {}

    @resource().list (error, resourceArray) =>
      return callback(error) if error

      @_list = resourceArray.map (resource) =>
        new @type(resource, @client(), props)

      # only creates a hash table if collection has a key
      if @key
        @_hash = {}

        for model in @_list
          key = model.resource()[@key]

          @_hash[key] = model

      callback(null, @)


  refresh: (callback) ->
    @loadCollection(callback)


  add: (model) ->
    if @key?
      key = model.resource()[@key]
      @_hash[key] = model

    @_list.push(model)


  get: (key) ->
    # Return entire collection if no key is provided
    return @_list unless key

    if _isNumber(key)
      model = @_list[key]
    else
      model = @_hash[key]

    if model?
      return model
    else
      throw new Error "No object in the #{@type.name}s collection
                      for that value."


  getAll: ->
    @_list
