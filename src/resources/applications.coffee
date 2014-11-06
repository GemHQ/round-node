
module.exports = class Applications

  constructor: (client, applicationsResource) ->
    @client = -> client
    for app in applicationsResource
      @[app.name] = app