
Developer = require './developer'

module.exports = class Developers

  constructor: (client) ->
    # !!!!! Does the user need access to the client????
    @client = -> client
    
    # 'credentials' requires email and pubkey
    # credentials can also take a privkey to authorize the client as a developer
    @create = (credentials, callback) ->
      client.resources().developers.create credentials, (error, developerResource) =>
          return callback(error) if error

          client._developer = new Developer(client, developerResource)

          if credentials.privkey
            client.patchboard().context.authorize 'Gem-Developer', credentials
          
          callback null, client._developer