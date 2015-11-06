Base = require('./base')
Wallet = require('./wallet')
Wallets = require('./wallets')
Devices = require('./devices')
Promise = require('bluebird')
{promisify} = Promise


module.exports = class User extends Base

  constructor: ({resource, client}) ->
    @client = client
    @resource = resource
    {@email, @url, @first_name, @last_name, @user_token,
    @default_wallet, @key, @phone_number} = resource


  wallets: ({fetch} = {}) ->
    @getAssociatedCollection({
      collectionClass: Wallets,
      name: 'wallets',
      fetch: fetch
    })


  wallet: ->
    Promise.resolve(@_wallet) if @_wallet

    @resource.default_wallet.get = promisify(@resource.default_wallet.get)
    @resource.default_wallet.get()
    .then (resource) => @_wallet = new Wallet({resource, @client})
    .catch (error) -> throw new Error(error)


  devices: ->
    resource = @client.resources.devices_query({@email})
    devices = new Devices({resource, @client})
    Promise.resolve(devices)