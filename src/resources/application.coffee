
Users = require './users'
MissingCredentialError = require('../errors').MissingCredentialError

module.exports = class Application

  constructor: (resource, client) ->
    # !!!!! WHICH PROPERTIES SHOULD WE MAKE DIRECTLY ACCESSIBLE ?????
    # NAME, API_TOKEN, URL, KEY?
    {@name, @api_token, @url, @key} = resource
    @resource = -> resource
    @client = -> client

  
  users: (callback) ->
    return callback(null, @_users) if @_users

    usersResource = @resource().users
    new Users usersResource, @client(), (error, users) ->
      return callback(error) if error

      @_users = users
      callback null, @_users
  
  # ALERT: THIS SHOULD BE AYNC, MAKING A CALL TO .LIST
  # users: () ->
  #   unless @_users
  #     @_users = new Users @resource().users, @client()
    
  #   @_users

  # ALERT: THIS SHOULD BE AYNC, MAKING A CALL TO .LIST
  rules: () ->
    unless @_rules
      @_rules  = new Rules @resource().rules, @client()
    
    @_rules

  # Note: credentials requires an api_token and a name
  beginInstanceAuthorization: (credentials, callback) ->
    requiredCredentials = ['name', 'api_token']

    for credential in requiredCredentials
      if credential not of credentials
        return callback(MissingCredentialError(credential))

    @resource().authorize_instance credentials, (error, applicationInstance) ->
      return callback(error) if error

      # applicationInstnace is a useless object - nothing can be done with it
      callback null, applicationInstance

  # Note: credentials requires an api_token and an instance_id
  finishInstanceAuthorization: (credentials) ->
    requiredCredentials = ['instance_id', 'api_token']

    for credential in requiredCredentials
      if credential not of credentials
        return callback(MissingCredentialError(credential))

    @client().patchboard().context.authorize 'Gem-Application', credentials
    return @

