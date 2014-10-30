
crypto = require 'crypto'

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
          # !!! what is the comma doing? !!!
          return scheme, """
            #{@schemes[scheme]['credential']},
            #{@devSignature(requestArgs['body'])}
            """
        else
          # !!! what is the comma doing? !!!
          scheme, @schemes[scheme]['credential']

  devSignature: (requestBody) -> 
    body = JSON.parse requestBody
    key = crypto.createSign 


  formatParams: (params) ->
    parts = for key, value of params
      "#{key}=\"#{value}\""
    parts.join(", ")


for x of obj
  console.log x



c = """
#{a} and
#{b}
"""



































