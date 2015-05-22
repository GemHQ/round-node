
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
      name: 'users'
      callback 
    }) 
    # return callback(null, @_users) if @_users

    # resource = @resource.users
    # users = new Users({resource, @client})

    # users.loadCollection (error, users) =>
    #   return callback(error) if error

    #   @_users = users
    #   callback(null, @_users)



