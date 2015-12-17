Promise = require('bluebird')
{promisify} = Promise


module.exports = class Collection

  _isNumber = (n) ->
    !isNaN(parseFloat(n)) && isFinite(n)


  constructor: ({resource, client, options}, callback) ->
    @resource = resource
    @client = client
    # an arry of models is populated for all resource types
    @_list = []
    # a hash table is populated if the model provides a key
    # ex: Accounts has a key property of 'name'
    @_hash = {}
    # options allows a Collection to add non-standard props
    # ex: wallets needs access to the application
    for key, value of options
      @[key] = value


  loadCollection: (options={}) ->
    # options is only used in cases where a collection needs
    # additional info at initialization time.
    # ex: when calling wallet.accounts you need to pass the wallet
    # so that all of the accounts can be created with a refrence to
    # the wallet that they belong to.
    if typeof @resource == 'function'
      # construct the resource without any query params
      resource = @resource({})
    else
      {resource} = @

    resource.list = promisify(resource.list)
    resource.list()
    .then((data) =>
      resourceArray = data.elements
      @_list = resourceArray.map (resource) =>
        options.resource = resource
        options.client = @client
        # type is defined on the child class
        new @type(options)

      # only creates a hash table if collection has a key
      # key is defined on the child class
      if @key
        @_hash = {}

        for model in @_list
          key = model.resource[@key]

          @_hash[key] = model

      return @
    )
    .catch (error) -> throw new Error(error)



  refresh: (options={}) -> @loadCollection(options)


  add: (model) ->
    if @key?
      key = model
      @_hash[key] = model

    @_list.push(model)


  get: (key) ->
    # Return entire collection if no key is provided
    return Promise.resolve(@_list) unless key?

    if _isNumber(key)
      model = @_list[key]
    else
      model = @_hash[key]

    if model?
      return Promise.resolve(model)
    else
      Promise.reject(
        "No object in the #{@type.name}s collection for that value."
      )


  getAll: -> @_list
