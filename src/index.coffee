Patchboard = require "patchboard-js"

Context = require "./context"
Client = require "./client"


defaultUrl = 'http://localhost:8999'
defaultNetwork = 'testnet3'


module.exports = {

  url: gemUrl

  client: (url=defaultUrl,network=defaultNetwork, callback) ->
    if @patchboard?
      callback null, new Client(@patchboard)
    else
      Patchboard.discover url, {context: Context}, (error, @patchboard) =>
        if error
          callback error if callback
        else
          callback(null, new Client(@patchboard)) if callback

  

  # scheme is an object
  # authenticate: (scheme) ->
  #   url = args.url || defaultUrl
  #   network = args.network || defaultNetwork
  #   if scheme.developer then return @authenticateDeveloper url, scheme.developer
  #   if scheme.application then return @authenticateApplication url scheme.application
  #   if scheme.device then return @authenticateDevice url scheme.device
  #   if scheme.otp then return @authenticateOtp url scheme.otp
  #   else throw "Supported authentication schemes are #{Object.keys(Context.schemes.keys).join(' ')}"

  # authenticateDeveloper: (url, developer, network, callback) ->
  #   if developer.email and developer.privkey
  #     client = @client url, network, (error, developer) ->



}


func = (a=1, b, c=2, d) ->
  console.log a, b, c, d
