
Transaction = require './transaction'
Collection = require './collection'


module.exports = class Transactions extends Collection

  type: Transaction
  key: 'url'

