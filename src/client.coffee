{SCHEMES} = require './context'
Application = require './resources/application'
Users = require './resources/users'
User = require './resources/user'
Account = require './resources/account'
Wallet = require './resources/wallet'
Promise = require 'bluebird'
{promisify} = Promise


set_application = (application, client) ->
  client.application = application


module.exports = class Client

  constructor: (patchboard) ->
    @patchboard = patchboard
    @resources = patchboard.resources
    @context = patchboard.context
    @users = new Users({resource: @resources.users, client: @})


  authenticate_application: ({admin_token, api_token, totp_secret}) ->
    @patchboard.context.authorize 'Gem-Application', arguments[0]
    @authenticate_identify({api_token})

    @application({totp_secret})


  authenticate_identify: ({api_token}) ->
    @patchboard.context.authorize('Gem-Identify', arguments[0])


  authenticate_device: ({email, api_token, device_token}) ->
    @patchboard.context.authorize 'Gem-Device', arguments[0]
    @authenticate_identify({api_token})

    @user {email}

   
  application: ({totp_secret}) ->    
    return Promise.resolve(@_application) if @_application

    @resources.app.get = promisify(@resources.app.get)
    @resources.app.get()
    .then (resource) =>
      @_application = new Application({resource, client: @, totp_secret})
    .catch (error) -> error


  user: ({email}) ->
    resource = @resources.user_query({email})
    resource.get = promisify(resource.get)
    resource.get()
    .then (resource) => new User({resource, client: @})
    .catch (error) -> error


