
crypto = require 'crypto'
base64url = require 'base64-url'
credentialFields = [
  'app_url', 'api_token', 'user_url', 'user_token', 'device_id',
  'instance_id', 'key', 'secret', 'email', 'privkey' ]

# Adds a 0 to dates less than 10.
# Ex. 3 becomes 03
formatDate = (date) -> 
    if date < 10 then "0#{date}" else "#{date}"


module.exports = class Context

  constructor: ->
    @schemes =
      'Gem-Developer':
        usage: null
      'Gem-Application':
        usage: null
      'Gem-User':
        usage: null
      'Gem-OOB-OTP':
        usage: null

  # Supply auth scheme credentials for a particular auth scheme
  # Creates an authorization string that will be placed in the header
  authorize: (scheme, credentials) ->
    params = {}
    
    return if scheme not of @schemes
    
    for field of credentials
      if field in credentialFields
        # adds the credential to the Context instance
        @[field] = credentials[field]
        if field not in ['privkey', 'app_url', 'user_url']
          params[field] = credentials[field]

    @schemes[scheme]['credentials'] = @formatParams params


  # Called by Patchboard on every request
  authorizer: (schemes, resource, action, request) ->
    body =  if 'body' of request then request['body'] else '{}'

    return {scheme: '', credential: ''} if arguments.length < 4

    for scheme in schemes
      if scheme of @schemes and 'credentials' of @schemes[scheme]
        if scheme is 'Gem-Developer'
          return {
            scheme,
            credential: "#{@schemes[scheme]['credentials']},signature=\"#{@devSignature(body)}\""
          }
        else
          { scheme, credential: @schemes[scheme]['credentials'] }


  devSignature: (requestBody) ->
    signer = crypto.createSign 'RSA-SHA256'
    date = new Date()
    content =  "#{requestBody}-#{date.getUTCFullYear()}/#{formatDate(date.getUTCMonth() + 1)}/#{formatDate(date.getUTCDate())}"
    console.log content
    signer.update content
    signature = signer.sign @privkey
    base64url.encode signature


  formatParams: (params) ->
    parts = for key, value of params
      "#{key}=\"#{value}\""
    parts.join(", ")
