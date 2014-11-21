
MissingCredentialError = require('./errors').MissingCredentialError



checkCredentials = (credentials, requiredCredentials, callback) ->
  for credential in requiredCredentials
    if credential not of credentials
      return callback MissingCredentialError(credential)

module.exports = {

  checkCredentials

}