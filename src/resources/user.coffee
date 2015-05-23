
Wallets = require('./wallets')
Base = require('./base')
Devices = require('./devices')

module.exports = class User extends Base

  constructor: ({resource, client}) ->
    @client = client
    @resource = resource
    {@email, @url, @first_name, @last_name, @user_token,
    @default_wallet} = resource


  wallets: (callback) ->
    @getAssociatedCollection({
      collectionClass: Wallets,
      name: 'wallets',
      callback
    })


  wallet: (callback) ->
    @Wallets (error, wallets) ->
      return callback(error) if error

      callback(null, wallets.get(0))


  devices: (callback) ->
    resource = @client.resources.devices_query({@email})
    devices = new Devices({resource, @client})
    callback(null, devices)








    # return callback(null, @_wallets) if @_wallets

    # resource = @resource.wallets
    # wallets = new Wallets({resource, @client})

    # wallets.loadCollection (error, wallets) =>
    #   return callback(error) if error

    #   @_wallets = wallets
    #   callback(null, @_wallets)


  # update: ({email, first_name, last_name}, callback) ->
  #   @resource.update content, (error, resource) =>
  #     return callback(error) if error

  #     @resource = resource
  #     {@email, @first_name, @last_name} = resource

  #     callback(null, @)
