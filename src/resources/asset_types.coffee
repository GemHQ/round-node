AssetType = require './asset_type'
Collection = require './collection'
Promise = require('bluebird')
{promisify} = Promise


module.exports = class AssetTypes extends Collection


  type: AssetType


  create: ({name, network, protocol}) ->
    network ?= 'bcy'
    protocol ?= 'openassets'
    @resource.create = promisify(@resource.create)
    @resource.create({name, network, protocol})
    .then (resource) =>
      asset = new AssetType({resource, @client, @wallet})
      @add(asset)
      asset
    .catch (error) -> throw new Error(error)
