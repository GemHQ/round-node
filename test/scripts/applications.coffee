Round = require '../../src'
Application = require '../../src/resources/application'

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds, newUserContent} = credentials
bezDevCreds = {email: 'bez@gem.co', pubkey, privkey }


describe.skip 'Applications Resource', ->
  client = ''
  beforeEach (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      client = cli
      done(error)

  describe 'application.authorizeInstance', ->
    # Note: depends on their already existing a developer account for bez@gem.co
    it 'should authorize client as an application instance', (done) ->
      client.authenticateDeveloper bezDevCreds, (error, developer) ->
        developer.applications (error, applications) ->
          defaultApp = applications.collection.default
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


describe.only 'Applications', ->
  client = developer = applications = ''
  
  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.developers.create newDevCreds(), (error, dev) ->
        dev.applications (error, apps) ->
          console.log apps
          client = cli; developer = dev; applications = apps
          done(error)

  it 'should memoize applications on the developer', ->
    expect(developer).to.have.a.property('_applications')


  describe 'applications.create', ->
    it 'should create a new Application Object', (done) ->
      name = "newApp"
      applications.create {name}, (error, application) ->
        expect(application).to.be.an.instanceof(Application)
        done(error)

    it 'should add new application to developer._applications.collection', ->
      expect(developer._applications.collection).to.have.property('newApp')

  describe 'applications.refresh', ->
    it 'should return applications object with new application', (done) ->
      applications.refresh (error, applications) ->
        expect(applications.collection).to.have.property('newApp')
        done(error)


