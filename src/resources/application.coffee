
module.exports = class Application

  constructor: (client, resource) ->
    # !!!!! WHICH PROPERTIES SHOULD WE MAKE DIRECTLY ACCESSIBLE ?????
    # NAME, API_TOKEN, URL, KEY? 
    {@name, @api_token, @url, @key} = resource
    @resource = -> resource
    @client = -> client

  users: (callback) ->
    return callback(null, @_users) if @_users
    # !!!! NEEDS TO BE WRAPPED
    # ????? needs to go to server to fetch latest users ????
    callback null, @resource().users 
