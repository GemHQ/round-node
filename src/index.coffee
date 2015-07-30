Patchboard = require "patchboard-js"
Promise = require "bluebird"
Patchboard.discover = Promise.promisify(Patchboard.discover)
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

  client: (options={}) ->
    if @patchboard?
      Promise.resolve(new Client(@patchboard.spawn()))
    else
      url = options.url || URL
      Patchboard.discover url, {context: Context}
      .then((@patchboard) => new Client(@patchboard))
      .catch((error) -> throw new Error(error))
}
