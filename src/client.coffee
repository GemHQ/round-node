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
    @patchboard.context.authorize('Gem-Device', arguments[0])
    @authenticate_identify({api_token})

    @user({email})
    .then (user) ->
      user.resource.get = promisify(user.resource.get)
      user.resource.get()
    .then (resource) => new User({resource, client: @})
    .catch (error) -> throw new Error(error)

   
  application: ({totp_secret}) ->    
    return Promise.resolve(@_application) if @_application

    @resources.app.get = promisify(@resources.app.get)
    @resources.app.get()
    .then (resource) =>
      @_application = new Application({resource, client: @, totp_secret})
    .catch (error) -> error


  # The user console needs to be able to fetch a user
  # but since it does not use authenticate_device, it needs
  # a different way to make the call to get the user, hence the
  # fetch param.
  user: ({email}, fetch) ->
    resource = @resources.user_query({email})
    if fetch
      resource.get = promisify(resource.get)
      resource.get()
      .then (resource) =>
        new User({resource, client: @})
      .catch (error) =>
        throw new Error(error)
    else
      # since resource is not a full resource, we need to add the email
      # property because some methods on the user object require it.
      resource.email = email
      Promise.resolve(new User({resource, client: @}))


