

# class MissingCredentialError

#   constructor: (credential) ->
#     @name = 'Missing Credential Error'
#     @message = "You must provide a/an #{credential} in order
#                 to perform this action"
#     @stack = new Error().stack

#   @prototype = new Error()
#   @prototype.constructor = MissingCredentialError


MissingCredentialError = (credential) ->
  message = "Credentials is missing: #{credential}"
  
  error = new Error(message)
  error.type = 'Missing Credential Error'
  return error

ExistingAuthenticationError = () ->
  message = "This object is already authenticated.
            To override the authentication, provide
            the property: 'override: true'"
  error = new Error(message)
  error.type = "Existing Authentication Error"
  return error




module.exports = {

  MissingCredentialError

}

