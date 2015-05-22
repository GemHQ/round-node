
crypto = require 'crypto'
base64url = require 'base64-url'

# Adds a 0 to dates less than 10.
formatDate = (date) -> 
    if date < 10 then "0#{date}" else "#{date}"


module.exports = class Context

  @SCHEMES = {
    DEVICE: 'Gem-Device',
    APPLICATION: 'Gem-Application',
    IDENTIFY: 'Gem-Identify'
  }


  constructor: ->
    @schemes =
      'Gem-Identify':
        credentials: null
        params: ['api_token']
      'Gem-Application':
        credentials: null
        params: ['admin_token', 'api_token']
      'Gem-Device':
        credentials: null
        params: ['email', 'api_token', 'device_token']

  # Supply auth scheme credentials for a particular auth scheme
  # Creates an authorization string that will be placed in the header
  authorize: (scheme, credentials) ->
    if scheme not of @schemes
      throw new Error('invalid scheme')
    if Object.keys(credentials).length == 0
      throw new Error('credentials cannot be empty')

    formatedCreds = Object.keys(credentials)
      .filter((credKey) =>
        credKey in @schemes[scheme]['params']
      )
      .map((credKey) ->
        "#{credKey}=\"#{credentials[credKey]}\""
      )
      .join(', ')

    @schemes[scheme]['credentials'] = formatedCreds

    
    # for field of credentials
    #   if field in @schemes[scheme]['params']
    #     # adds the credential to the Context instance
    #     @[field] = credentials[field]
    #     if field not in ['privkey', 'app_url', 'user_url']
    #       params[field] = credentials[field]

    # @schemes[scheme]['credentials'] = @formatParams params


  # Called by Patchboard on every request
  authorizer: (schemes, resource, action, request) ->
    for scheme in schemes
      if @schemes[scheme]? and @schemes[scheme]['credentials']?
        return { scheme, credential: @schemes[scheme]['credentials'] }


    

    # for scheme in schemes
    #   if @schemes[scheme]? and  @schemes[scheme]['credentials']?
    #     if scheme is 'Gem-Developer'
    #       body = if request['body']? then request['body'] else '{}'
    #       timestamp = Math.round(Date.now() / 1000)
    #       return {
    #         scheme,
    #         credential: "#{@schemes[scheme]['credentials']},
    #                     signature=\"#{@devSignature(body, timestamp)}\",
    #                     timestamp=\"#{timestamp}\"",
    #       }
    #     else
    #       return { scheme, credential: @schemes[scheme]['credentials'] }


  # devSignature: (requestBody, timestamp) ->
  #   signer = crypto.createSign 'RSA-SHA256'
  #   content = "#{requestBody}-#{timestamp}"
  #   signer.update content
  #   signature = signer.sign @privkey
  #   base64url.encode signature


  # formatParams: (params) ->
  #   parts = for key, value of params
  #     "#{key}=\"#{value}\""
  #   parts.join(", ")
