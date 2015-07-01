Address = require './address'
Collection = require './collection'
Promise = require('bluebird')
{promisify} = Promise


module.exports = class Addresses extends Collection


  type: Address


  create: ->
    @resource.create = promisify(@resource.create)
    @resource.create()
    .then (resource) =>
      address = new Address({resource, @client})
      @add(address)
      address
    .catch (error) -> error
