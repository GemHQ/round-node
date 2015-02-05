Patchboard = require "patchboard-js"

Context = require "./context"
Client = require "./client"


defaultUrl = 'http://localhost:8999'
defaultNetwork = 'bitcoin_testnet'

module.exports = {

  client: (options, callback) ->
    # Makes options argument optional
    callback = arguments[0] if arguments.length == 1

    url = options.url || defaultUrl
    network = options.network || defaultNetwork
    
    if @patchboard?
      callback null, new Client(@patchboard.spawn())
    else
      Patchboard.discover url, {context: Context}, (error, @patchboard) =>
        if error
          callback error if callback
        else
          callback(null, new Client(@patchboard)) if callback

}
