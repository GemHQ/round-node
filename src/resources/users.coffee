
module.exports = class Users

  constructor: (client, resource) ->
    @client = -> client
    @resource = -> resource
  
  # requires email and wallet
  create: (content, callback) ->
    @client().resources().users.create content, (error, user) ->
      return callback(error) if error

      # !!!!! ADD NEW USER TO USERS LIST
      # !!!!! WRAP USER
      callback null, user

