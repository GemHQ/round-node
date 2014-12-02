
User = require './user'
Collection = require './collection'


module.exports = class Users extends Collection

  type: User
  
  # content requires email and wallet
  create: (content, callback) ->
    @resource().create content, (error, userResource) =>
      return callback(error) if error

      user = new User(userResource, @client())
      # the key is a reference to the resource's name
      # therefor it will update when the resource updates.
      @collection[user.resource().name] = user
      callback null, user

