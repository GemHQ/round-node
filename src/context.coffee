
crypto = require 'crypto'
base64url = require 'base64-url'
credentialFields = [
  'app_url', 'api_token', 'user_url', 'user_token', 'device_id',
  'instance_id', 'key', 'secret', 'email', 'privkey'
]

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
    
    if scheme not of @schemes
      return

    for field in credentialFields
      if field in credentials
        # add the credential to the Context instance
        @[field] = credentials[field]
        if field not in ['privkey', 'app_url', 'user_url']
          params[field] = options[field]

    @schemes[scheme]['credentials'] = @formatParams params


  # Select an Authorization scheme and supply credentials
  authorizer: (schemes, resource, action, requestArgs) ->
    
    # !!! first check if the user has provide a schemes object somehow !!!
    # !!! is schemes an object or an array? !!!
    
    for scheme in schemes
      if scheme in @schemes and 'credential' of @schemes[scheme]
        if scheme is 'Gem-Developer'
          return {
            scheme,
            credential: """
                      #{@schemes[scheme]['credential']},
                      #{@devSignature(requestArgs['body'])}
                      """
          }
        else
          { scheme, credential: @schemes[scheme]['credential'] }

  devSignature: (requestBody) -> 
    body = JSON.stringify requestBody
    signer = crypto.createSign 'RSA-SHA256'
    date = new Date()
    signer.update "#{requestBody}-#{date.getFullYear()}/#{date.getMonth() + 1}/#{date.getDate()}"
    signature = signer.sign @privkey
    base64url signature

  formatParams: (params) ->
    parts = for key, value of params
      "#{key}=\"#{value}\""
    parts.join(", ")



































