
Users = require './users'
Rules = require './rules'

module.exports = class Application

  constructor: (resource, client, options) ->
    {@name, @api_token, @url, @key} = resource
    @resource = -> resource
    @client = -> client

  
  users: (callback) ->
    return callback(null, @_users) if @_users

    resource = @resource().users
    users = new Users(resource, @client())
    
    users.loadCollection (error, users) =>
      return callback(error) if error

      @_users = users
      callback(null, @_users)
  

  rules: ->
    @_rules || new Rules @resource().rules, @client()
    

  # Credentials requires a name
  authorizeInstance: (credentials, callback) ->
    @resource().authorize_instance credentials, (error, applicationInstance) ->
      return callback(error) if error

      # applicationInstnace is a useless object - nothing can be done with it
      callback null, applicationInstance


  # Content requires a name property
  # Note: This does not update the key in the collection
  update: (content, callback) ->
    @resource().update content, (error, resource) =>
      return callback(error) if error

      @resource = -> resource
      @name = resource.name

      callback(null, @)


  reset: (callback) ->
    @resource().reset (error, resource) ->
      return callback(error) if error

      @resource = -> resource
      @api_token = resource.api_token

      callback(null, @)



