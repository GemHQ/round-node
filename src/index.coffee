Patchboard = require "patchboard-js"
Promise = require "bluebird"
Patchboard.discover = Promise.promisify(Patchboard.discover)
Context = require "./context"
Client = require "./client"


NETWORKS = {
  testnet: "bitcoin_testnet",
  bitcoin_testnet: "bitcoin_testnet",
  testnet3: "bitcoin_testnet",
  bitcoin: "bitcoin",
  mainnet: "bitcoin"
}


module.exports = {

  client: ({url, schemes}) ->
    if @patchboard?
      Promise.resolve(new Client(@patchboard.spawn()))
    else
      url ?= "https://api.gem.co"
      # allow schemes to be merged in to Context.
      # This functionality is needed for the web console.
      Context = Context.bind(null, schemes) if schemes?
      Patchboard.discover url, {context: Context}
      .then((@patchboard) => new Client(@patchboard))
      .catch((error) -> throw new Error(error))
}
