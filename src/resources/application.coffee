Users = require('./users')
Wallet = require('./wallet')
Wallets = require('./wallets')
Base = require('./base')
TOTP = require('onceler').TOTP
{promisify} = require('bluebird')

module.exports = class Application extends Base

  constructor: ({resource, client, totp_secret}) ->
    @resource = resource
    @client = client
    @totp_secret = totp_secret
    {@name, @api_token, @url} = resource


  authorize_instance: ({name}) ->
    @resource.authorize_instance = promisify(@resource.authorize_instance)
    @resource.authorize_instance arguments[0]


  users: ({fetch} = {}) ->
    @getAssociatedCollection({
      collectionClass: Users,
      name: 'users',
      fetch: fetch
    })


  wallets: ({fetch} = {}) ->
    @getAssociatedCollection({
      collectionClass: Wallets,
      name: 'wallets',
      options: {
        application: @
      },
      fetch: fetch
    })


  wallet: ({name} = {}) ->
    res = @resource.wallet_query({name})
    res.get = promisify(res.get)
    res.get()
    .then (resource) =>
      new Wallet({resource, client: @client, application: @})
    .catch (error) ->
      throw new Error(error)


  get_mfa: ->
    new TOTP(@totp_secret).now()
    
