Promise = require('bluebird')
{promisify} = Promise


module.exports = class Base

  # this method is used to retreive an associated collection
  # for any given model. (e.g. application.users will use getAssociation
  # to retreive and memoize a populated users collection.)
  # collectionClass = the class of the collection which you want to
  #                   populate and retreive
  # ARGUMENTS
  # name = the name of the collection that you wan to retreive
  # callback = provided by the developer. It ss called after the instance
  #            has been populated
  # resource = normally the respurce can be accessed via @resource, but if  
  #            you need to provide a custom resource then you can do so.
  #            This is used in account.transactions
  # options = non-standard props that a Collection might need.
  #           ex: Wallets needs access to the application it belongs to
  getAssociatedCollection: ({collectionClass, name, resource, options}) ->
    # if memoized, return the collection
    return  Promise.resolve(@["_#{name}"]) if @["_#{name}"]?
     
    options ?= {}

    # resource is the collection's resource
    # this would be similar to user.resource.users
    resource = resource || @resource[name]
    collectionInstance = new collectionClass({resource, @client, options})

    # populate the collection. loadCollection lives in the Collection class
    collectionInstance.loadCollection(options)
    .then (collectionInstance) =>
      # memoize the collection
      @["_#{name}"] = collectionInstance
    .catch (error) -> error


  update: (content) ->
    @resource.update = promisify(@resource.update)
    @resource.update(content)
    .then((resource) => 
      @resource = resource
      # Fix: replace with @_setProps once all classes have a PROPS_LIST
      for own key, val of content
        @[key] = val

      return @
    )
    .catch (error) -> error


  # Used to copy props from a resource to @
  # Useful during initialization of an object and
  # when the resource is updated
  # ARGUMENTS
  # propsList = an array of the properties that you want to copy
  # copyed = the object that the properties will be copyed from
  _setProps: (propsList, copyed) ->
    propsList.forEach (prop) =>
      @[prop] = copyed[prop]