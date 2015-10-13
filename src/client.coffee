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


  # The user console uses a users key to fetch a user
  user: ({email, key, url}) ->
    if key
      throw new Error('must provide a url') unless url
      resource = @resources.user_query("#{url}/users/#{key}");
      resource.get = promisify(resource.get)
      resource.get()
      .then (resource) =>
        new User({resource, client: @})
      .catch (error) =>
        throw new Error(error)
    else
      resource = @resources.user_query({email})
      # since resource is not a full resource, we need to add the email
      # property because some methods on the user object require it.
      resource.email = email
      Promise.resolve(new User({resource, client: @}))


  # used by web wallet and management console
  confirm_email: ({email_confirmation_token, key, url}) ->
    resource = @resources.user_query("#{url}/users/#{key}");
    resource.confirm_email = promisify(resource.confirm_email)
    resource.confirm_email({token: email_confirmation_token})
    .then (resource) => 
      new User({resource, client: @})
    .catch (error) ->
      throw new Error(error)


  wrapUserResource: ({resource}) ->
    new User({resource, client: @})