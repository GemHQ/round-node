Round = require '../../src'

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds, newUserContent} = credentials
bezDevCreds = {email: 'bez@gem.co', pubkey, privkey }


describe 'Applications Resource', ->
  client = ''
  beforeEach (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      client = cli
      done(error)

  describe 'application.authorizeInstance', ->
    # Note: dependds on their already existing a developer account for bez@gem.co
    it 'should create a new client with a property of patchboard', (done) ->
      client.authenticateDeveloper bezDevCreds, (error, developer) ->
        developer.applications (error, applications) ->
          defaultApp = applications.default
          {api_token} = defaultApp
          
          # # STEP 1
          # name = "newAppInstance#{Date.now()}"
          # defaultApp.beginInstanceAuthorization {name, api_token}, (error, applicationInstance) ->
          #   done(error)

          # STEP 2
          # instance_id comes from an email
          instance_id = 'u-mwQs2uNR9oksuOhZ9ahTHveAoOTxNNW18nQtgpa8o'
          defaultApp.finishInstanceAuthorization {api_token, instance_id}
          # makes sure client is properly authorized
          defaultApp.users().resource().list (error, applications) ->
            done(error)

  describe 'applications.create', ->
    it 'should create a new Application', (done) ->
      client.developers.create newDevCreds(), (error, developer) ->
        developer.applications (error, applications) ->
          name = "newApp#{Date.now()}"
          applications.create {name}, (error, application) ->
            done(error)