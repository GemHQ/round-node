
Users = require './users'
Rules = require './rules'
MissingCredentialError = require('../errors').MissingCredentialError

module.exports = class Application

  constructor: (resource, client, options) ->
    {@name, @api_token, @url, @key} = resource
    @resource = -> resource
    @client = -> client

  
  users: (callback) ->
    return callback(null, @_users) if @_users

    usersResource = @resource().users
    new Users usersResource, @client(), (error, users) =>
      return callback(error) if error

      @_users = users
      callback null, @_users
  

  rules: ->
    @_rules || new Rules @resource().rules, @client()
    

  # Credentials requires a name
  authorizeInstance: (credentials, callback) ->
    @resource().authorize_instance credentials, (error, applicationInstance) ->
      return callback(error) if error

      # applicationInstnace is a useless object - nothing can be done with it
      callback null, applicationInstance