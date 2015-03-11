
Wallets = require './wallets'

module.exports = class User

  constructor: (resource, client, options) ->
    @client = -> client
    @resource = -> resource
    {@email, @url, @first_name, @last_name, @user_token,
    @applications, @default_wallet, @subscriptions} = resource


  wallets: (callback) ->
    return callback(null, @_wallets) if @_wallets

    resource = @resource().wallets
    wallets = new Wallets(resource, @client())

    wallets.loadCollection (error, wallets) =>
      return callback(error) if error

      @_wallets = wallets
      callback(null, @_wallets)


  # content can take an email, first_name, or last_name
  update: (content, callback) ->
    @resource().update content, (error, resource) =>
      return callback(error) if error

      @resource = -> resource
      {email, @first_name, @last_name} = resource

      callback(null, @)
