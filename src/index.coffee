Patchboard = require "patchboard-js"

Context = require "./context"
Client = require "./client"


defaultUrl = 'http://localhost:8999'
defaultNetwork = 'testnet3'
schemes = ['developer', 'application', 'device', 'otp']

module.exports = {

  url: defaultUrl

  # default values are only used if the user
  # explicitely eneters 'null' or 'undefined' for those values
  client: (url=defaultUrl, network=defaultNetwork, callback) ->
    if @patchboard?
      callback null, new Client(@patchboard)
    else
      Patchboard.discover url, {context: Context}, (error, @patchboard) =>
        if error
          callback error if callback
        else
          callback(null, new Client(@patchboard)) if callback


  # args is an object
  authenticate: (args, callback) ->
    url = args.url || defaultUrl
    network = args.network || defaultNetwork
    if args.developer then return @authenticateDeveloper url, args.developer, network, callback
    if args.application then return @authenticateApplication url, args.application, network, callback
    if args.device then return @authenticateDevice url, args.device, network, callback
    if args.otp then return @authenticateOtp url, args.otp, network, callback
    else throw """Please supply a supported authentication scheme.
                  Supported authentication schemes are #{schemes.join(', ')}"""


  authenticateDeveloper: (url, developer, network, callback) ->
    if 'email' of developer and 'privkey' of developer
      # create a new client object
      @client url, network, (error, client) ->
        # authorize the client with developer permissions
        client.patchboard.context.authorize 'Gem-Developer', developer
        
        callback error if error
        callback null, client
    else
      throw "Must provide email and privkey"


}
