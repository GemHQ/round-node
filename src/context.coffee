
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


  constructor: (schemes) ->
    # mfa_token is set on account.pay if the transaction
    # is being initiated by an application wallet
    @mfa_token = null
    @schemes = {
      'Gem-Identify': {
        credentials: null,
        params: ['api_token'],
      },
      'Gem-Application': {
        credentials: null,
        params: ['admin_token', 'api_token']
      },
      'Gem-Device': {
        credentials: null,
        params: ['email', 'api_token', 'device_token']
      }
    }
    # Merge in any schemes that may be passed in.
    # This is needed for the web console because it uses
    # schemes that the clients don't contain.
    if schemes?
      for own key, value of schemes
        @schemes[key] = value


  # Supply auth scheme credentials for a particular auth scheme
  # Creates an authorization string that will be placed in the header
  authorize: (scheme, credentials) ->
    if scheme not of @schemes
      throw new Error('invalid scheme')
    if Object.keys(credentials).length == 0
      throw new Error('credentials cannot be empty')

    @schemes[scheme]['credentials'] = credentials


  # Called by Patchboard on every request
  authorizer: (schemes, resource, action, request) ->
    for scheme in schemes
      if @schemes[scheme]? and @schemes[scheme]['credentials']?
        credential = @formatCredsForScheme(scheme)
        return { scheme, credential }


  formatCredsForScheme: (scheme) ->
    credentials = @schemes[scheme]['credentials']
    params = @schemes[scheme]['params']
    
    compiled = Object.keys(credentials)
      .filter((credKey) ->
        params.indexOf(credKey) > -1
      )
      .map((credKey) ->
        "#{credKey}=\"#{credentials[credKey]}\""
      )
      .join(', ')
    
    compiled = compiled.concat(", mfa_token=\"#{@mfa_token}\"") if @mfa_token
    compiled


  setMFA: (mfa_token) ->
    @mfa_token = mfa_token