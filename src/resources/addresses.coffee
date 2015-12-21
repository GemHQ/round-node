Address = require './address'
Collection = require './collection'
Promise = require('bluebird')
{promisify} = Promise


module.exports = class Addresses extends Collection


  type: Address


  create: ->
    rsrc = @resource({})
    rsrc.create = promisify(rsrc.create)
    rsrc.create()
    .then (resource) =>
      address = new Address({resource, @client})
      @add(address)
      address
    .catch (error) -> throw new Error(error)
