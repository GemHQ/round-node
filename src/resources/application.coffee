Users = require './users'

module.exports = class Application

  constructor: (client, resource) ->
    # !!!!! WHICH PROPERTIES SHOULD WE MAKE DIRECTLY ACCESSIBLE ?????
    # NAME, API_TOKEN, URL, KEY? 
    {@name, @api_token, @url, @key} = resource
    @resource = -> resource
    @client = -> client

  users: (callback) ->
    return callback(null, @_users) if @_users
    # ?????  shouldn't we be making a call to .list here? Needs to go to server to fetch latest users ????
    callback null, new Users @client(), @resource().users 


  rules: (callback) ->
    return callback(null, @_rules) if @_rules
    
    callback null, @resource().rules



