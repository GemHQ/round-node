
module.exports = class Asset

  constructor: ({resource, client, wallet}) ->
    @client = client
    @resource = resource
    @wallet = wallet
    {@name, @network, @protocol, @fungible, @locked} = resource