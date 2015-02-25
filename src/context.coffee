
crypto = require 'crypto'
base64url = require 'base64-url'

# Adds a 0 to dates less than 10.
formatDate = (date) -> 
    if date < 10 then "0#{date}" else "#{date}"


module.exports = class Context

  constructor: ->
    @schemes =
      'Gem-Developer':
        usage: null
        params: ['email', 'privkey']
      'Gem-Application':
        usage: null
        params: ['app_url', 'api_token', 'instance_id']
      'Gem-Device':
        usage: null
        params: ['app_url', 'api_token', 'user_url', 'user_token', 'device_id']
      'Gem-User':
        usage: null
        params: ['app_.url', 'api_token', 'instance_id']
      'Gem-OOB-OTP':
        usage: null
        params: ['key', 'secret', 'api_token']

  # Supply auth scheme credentials for a particular auth scheme
  # Creates an authorization string that will be placed in the header
  authorize: (scheme, credentials) ->
    params = {}
    
    return if scheme not of @schemes
    
    for field of credentials
      if field in @schemes[scheme]['params']
        # adds the credential to the Context instance
        @[field] = credentials[field]
        if field not in ['privkey', 'app_url', 'user_url']
          params[field] = credentials[field]

    @schemes[scheme]['credentials'] = @formatParams params


  # Called by Patchboard on every request
  authorizer: (schemes, resource, action, request) ->
    return {scheme: '', credential: ''} if arguments.length < 4
    
    for scheme in schemes
      if @schemes[scheme]? and  @schemes[scheme]['credentials']?
        if scheme is 'Gem-Developer'
          body = if request['body']? then request['body'] else '{}'
          timestamp = Math.round(Date.now() / 1000)
          return {
            scheme,
            credential: "#{@schemes[scheme]['credentials']},
                        signature=\"#{@devSignature(body, timestamp)}\",
                        timestamp=\"#{timestamp}\"",
          }
        else
          return { scheme, credential: @schemes[scheme]['credentials'] }


  devSignature: (requestBody, timestamp) ->
    signer = crypto.createSign 'RSA-SHA256'
    content = "#{requestBody}-#{timestamp}"
    signer.update content
    signature = signer.sign @privkey
    base64url.encode signature


  formatParams: (params) ->
    parts = for key, value of params
      "#{key}=\"#{value}\""
    parts.join(", ")
