AssetType = require './asset_type'
Collection = require './collection'
Promise = require('bluebird')
{promisify} = Promise


module.exports = class AssetTypes extends Collection


  type: AssetType


  create: ({name, network, protocol, ticker_symbol}) ->
    network ?= 'bcy'
    protocol ?= 'openassets'

    rsrc = @resource({})
    rsrc.create = promisify(rsrc.create)
    rsrc.create({name, network, protocol, ticker_symbol})
    .then (resource) =>
      assetType = new AssetType({resource, @client, @wallet})
      @add(assetType)
      assetType
    .catch (error) -> throw new Error(error)
