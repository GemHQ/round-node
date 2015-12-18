Asset = require './asset'
Collection = require './collection'
Promise = require('bluebird')
{promisify} = Promise


module.exports = class Assetes extends Collection


  type: Asset


  create: ->
    @resource.create = promisify(@resource.create)
    @resource.create()
    .then (resource) =>
      asset = new Asset({resource, @client})
      @add(asset)
      asset
    .catch (error) -> throw new Error(error)
