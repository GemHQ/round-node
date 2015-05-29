{SCHEMES} = require './context'
# Developers = require './resources/developers'
# Developer = require './resources/developer'
Application = require './resources/application'
Users = require './resources/users'
User = require './resources/user'
Account = require './resources/account'
Wallet = require './resources/wallet'


set_application = (application, client) ->
  client.application = application


module.exports = class Client

  constructor: (patchboard) ->
    @patchboard = patchboard
    @resources = patchboard.resources
    @context = patchboard.context
    @users = new Users({resource: @resources.users, client: @})


  authenticate_application: ({admin_token, api_token, totp_secret}, callback) ->
    @patchboard.context.authorize 'Gem-Application', arguments[0]
    @authenticate_identify({api_token})

    @application {totp_secret}, (error, application) ->
      callback(error, application)


  authenticate_identify: ({api_token}) ->
    @patchboard.context.authorize('Gem-Identify', arguments[0])


  # Credentials requires {email, api_token, device_token}
  authenticate_device: ({email, api_token, device_token}, callback) ->
    @patchboard.context.authorize 'Gem-Device', arguments[0]
    @authenticate_identify({api_token})

    @user {email}, (error, user) ->
      callback(error, user)

   
  application: ({totp_secret}, callback) ->
    if arguments.length == 1
      callback = arguments[0]
      totp_secret = null
    
    return callback(null, @_application) if @_application

    @resources.app.get (error, resource) =>
      return callback(error) if error

      @_application = new Application({resource, client: @, totp_secret})
      callback(null, @_application)


  user: ({email}, callback) ->
    resource = @resources.user_query({email})

    resource.get (error, resource) =>
      callback(error, new User({resource, client: @}))


