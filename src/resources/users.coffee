
User = require './user'
module.exports = class Users

  constructor: (client, resource) ->
    @client = -> client
    @resource = -> resource
  
  # requires email and wallet
  create: (content, callback) ->
    @client().resources().users.create content, (error, userResource) =>
      return callback(error) if error
      # !!!!! ADD NEW USER TO USERS LIST
      # ????? MEMOIZE USER ??????
      user = new User @client(), userResource
      callback null, user

