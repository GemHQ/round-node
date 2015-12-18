
module.exports = class Asset

  constructor: ({resource, client}) ->
    @client = client
    @resource = resource
    {@name, @network, @protocol, @fungible, @locked} = resource