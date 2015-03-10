
Subsciption = require 'subscription'
Collection = require './collection'


module.exports = class Subsciptions extends Collection

  constructor: (resource, client) ->
    @client = -> client
    @resource = -> resource


  create: (content, callback) ->
    # Create a new Subscription on all addresses contained by this collection's
    # parent object.
    # Return the new round.Subscription object.
    # Required arguments:
    # callback_url -- URI of an active endpoint which can receive notifications
    
    content.subscribed_to = "address"

    @resource().create content, (error, resource) =>
      return callback(error) if error

      subscription = new Subscription(resource, client())
      @add(subscription)












