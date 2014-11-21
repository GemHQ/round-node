
User = require './user'
module.exports = class Users

  constructor: (resource, client) ->
    @client = -> client
    @resource = -> resource
    @collection = {}
  
  # requires email and wallet
  create: (content, callback) ->
    @client().resources().users.create content, (error, userResource) =>
      return callback(error) if error
      # !!!!! ADD NEW USER TO USERS LIST
      # ????? MEMOIZE USER ??????
      user = new User(userResource, @client())
      callback null, user

