
Address = require './address'
Collection = require './collection'

module.exports = class Addresses extends Collection


  type: Address
  key: 'string'


  create: (callback) ->
    @resource().create (error, resource) =>
      return callback(error) if error

      address = new Address(resource, @client())
      @add(resource.string, address)
      
      callback null, address