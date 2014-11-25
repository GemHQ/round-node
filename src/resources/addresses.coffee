
Address = require './address'
Collection = require './collection'

module.exports = class Addresses extends Collection

  type: Address

  create: (callback) ->
    @resource().create (error, addressResource) =>
      return callback(error) if error

      address = new Address(addressResource, @client())
      @collection[address.resource().string] = address
      
      callback null, address