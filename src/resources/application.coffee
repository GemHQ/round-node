
Users = require('./users')
Wallets = require('./wallets')
Base = require('./base')
OTP = require('speakeasy')

module.exports = class Application extends Base

  constructor: ({resource, client, totp_secret}) ->
    @resource = resource
    @client = client
    @totp_secret = totp_secret
    {@name, @api_token, @url} = resource


  authorize_instance: ({name}, callback) ->
    @resource.authorize_instance arguments[0], (error, instance) ->
      callback(error, instance)


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


  get_mfa: ->
    OTP.totp({key: @totp_secret})
