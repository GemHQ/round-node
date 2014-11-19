Users = require './users'

module.exports = class Application

  constructor: (client, resource) ->
    # !!!!! WHICH PROPERTIES SHOULD WE MAKE DIRECTLY ACCESSIBLE ?????
    # NAME, API_TOKEN, URL, KEY? 
    {@name, @api_token, @url, @key} = resource
    @resource = -> resource
    @client = -> client

  users: () ->
    unless @_users
      @_users = new Users @client(), @resource().users
    
    @_users

  rules: () ->
    unless @_rules
      @_rules  = new Rules @client(), @resource().rules
    
    @_rules

  # Note: credentials requires an api_token and a name
  beginInstanceAuthorization: (credentials, callback) ->
    requiredCredentials = ['name', 'api_token']

    for credential in requiredCredentials
        if credential not of credentials
          throw "You must provide #{credential} in order to begin authorizing as an application instance"

    @resource().authorize_instance credentials, (error, applicationInstance) ->
      return callback(error) if error

      # applicationInstnace is a useless object - nothing can be done with it
      callback null, applicationInstance

  # Note: credentials requires an api_token and an instance_id
  finishInstanceAuthorization: (credentials) ->
    requiredCredentials = ['instance_id', 'api_token']

    for credential in requiredCredentials
        if credential not of credentials
          throw "You must provide #{credential} in order to begin authorizing as an application instance"

    @client().patchboard().context.authorize 'Gem-Application', credentials
    return @

