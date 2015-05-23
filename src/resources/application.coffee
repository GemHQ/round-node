
Users = require('./users')
Wallets = require('./wallets')
Base = require('./base')

module.exports = class Application extends Base

  constructor: ({resource, client}) ->
    @resource = resource
    @client = client
    {@name, @api_token, @url} = resource
    @wallets = new Wallets({
      resource: resource.wallets,
      client,
      application: @
    })


  users: (callback) ->
    @getAssociatedCollection({
      collectionClass: Users,
      name: 'users',
      callback: callback
    })


  wallets: (callback) ->
    @getAssociatedCollection({
      collectionClass: Wallets,
      name: 'wallets',
      options: {
        application: @
      },
      callback: callback
    })