Asset = require './asset'
Collection = require './collection'
Promise = require('bluebird')
{promisify} = Promise


module.exports = class Assetes extends Collection


  type: Asset


  create: ({name, network, protocol}) ->
    network ?= 'bcy'
    protocol ?= 'openassets'
    @resource.create = promisify(@resource.create)
    @resource.create({name, network, protocol})
    .then (resource) =>
      asset = new Asset({resource, @client, @wallet})
      @add(asset)
      asset
    .catch (error) -> throw new Error(error)
