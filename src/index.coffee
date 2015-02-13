Patchboard = require "patchboard-js"

Context = require "./context"
Client = require "./client"


MAINNET_URL = "https://api.gem.co"
SANDBOX_URL = "https://api-sandbox.gem.co"


module.exports = {

  client: (options, callback) ->
    # Makes options argument optional
    if arguments.length == 1
      callback = arguments[0] 
      options = {}

    url = options.url || if options.network == 'bitcoin' then MAINNET_URL else SANDBOX_URL
    
    if @patchboard?
      callback(null, new Client(@patchboard.spawn()))
    else
      Patchboard.discover url, {context: Context}, (error, @patchboard) =>
        callback(error, new Client(@patchboard)) if callback

}
