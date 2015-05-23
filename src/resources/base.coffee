

module.exports = class Base

  # used to memoize collection instance
  # this would be similar to memoizing _users
  collectionInstance: null


  # this method is used to retreive an associated collection
  # for any given model. (e.g. application.users will use getAssociation
  # to retreive and memoize a populated users collection.)
  # collectionClass = the class of the collection which you want to
  #                   populate and retreive
  # name = the name of the collection that you wan to retreive
  # callback = provided by the developer. It ss called after the instance
  #            has been populated
  # options = non-standard props that a Collection might need.
  #           ex: Wallets needs access to the application it belongs to
  getAssociatedCollection: ({collectionClass, name, options, callback}) ->
    # if memoized, return the collection
    return  callback(null, @collectionInstance) if @collectionInstance?
     
    # resource is the collection's resource
    # this would be similar to user.resource.users
    resource = @resource[name]
    collectionInstance = new collectionClass({resource, @client, options})

    # populate the collection. loadCollection lives in the Collection class
    collectionInstance.loadCollection (error, collectionInstance) ->
      return callback(error) if error

      # memoize the collection
      @collectionInstance = collectionInstance
      callback(null, @collectionInstance)


  update: (content, callback) ->
    @resource.update content, (error, resource) =>
      return callback(error) if error
      
      @resource = resource
      for own key, val of content
        @[key] = val

      callback(null, @)