
module.exports = class Context
  constructor: ->
    @schemes = {}

  # Supply this context with credentials for a particular
  # Authorization scheme
  authorize: (scheme, params) ->
    if scheme == "Basic"
      {login, password} = params
      encoded = new Buffer("#{login}:#{password}").toString("base64")
      @schemes[scheme] = encoded
    else
      @schemes[scheme] = @format_params(params)

  # Select an Authorization scheme and supply credentials
  authorizer: (schemes, resource, action) ->
    for scheme in schemes
      if credential = @schemes[scheme]
        return {scheme, credential}

    return undefined

  format_params: (params) ->
    parts = for key, value of params
      "#{key}=\"#{value}\""
    parts.join(", ")


