Patchboard = require "patchboard-js"

Context = require "./context"
Client = require "./client"


URL = "https://api.gem.co"


NETWORKS = {
  testnet: "bitcoin_testnet",
  bitcoin_testnet: "bitcoin_testnet",
  testnet3: "bitcoin_testnet",
  bitcoin: "bitcoin",
  mainnet: "bitcoin"
}


module.exports = {

  client: (options, callback) ->
    if arguments.length == 1
      callback = arguments[0]
      options = {}

    if @patchboard?
      callback(null, new Client(@patchboard.spawn()))
    else
      url = options.url || URL
      Patchboard.discover url, {context: Context}, (error, @patchboard) =>
        callback(error, new Client(@patchboard)) if callback
}
