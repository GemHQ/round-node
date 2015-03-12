Patchboard = require "patchboard-js"

Context = require "./context"
Client = require "./client"


MAINNET_URL = "https://api.gem.co"
SANDBOX_URL = "https://api-sandbox.gem.co"

NETWORKS = {
  testnet: "bitcoin_testnet",
  bitcoin_testnet: "bitcoin_testnet",
  testnet3: "bitcoin_testnet",
  bitcoin: "bitcoin",
  mainnet: "bitcoin"
}


module.exports = {

  client: (options, callback) ->
    # Makes options argument optional
    if arguments.length == 1
      callback = arguments[0]
      options = {}

    # in case options was set to null or undefined it
    # is assigned to an empty object instead
    options ?= {}

    network = NETWORKS[options.network] || "bitcoin_testnet"
    url = options.url || if network == 'bitcoin' then MAINNET_URL else SANDBOX_URL

    if @patchboard?
      callback(null, new Client(@patchboard.spawn(), network))
    else
      Patchboard.discover url, {context: Context}, (error, @patchboard) =>
        callback(error, new Client(@patchboard, network)) if callback

}
