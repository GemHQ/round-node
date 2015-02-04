Round = require '../../src'
Application = require '../../src/resources/application'
Users = require '../../src/resources/users'
Rules = require '../../src/resources/rules'

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds, newUserContent} = credentials
bezDevCreds = {email: 'bez@gem.co', pubkey, privkey }


describe 'Applications Resource', ->
  client = defaultApp = applications = ''
  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      client = cli
      # Note: depends on their already existing a developer account for bez@gem.co
      client.authenticateDeveloper bezDevCreds, (error, developer) ->
        developer.applications (error, apps) ->
          defltApp = apps.collection.default
          {api_token} = defltApp
          
          # STEP 1
          # name = "newAppInstance#{Date.now()}"
          # defltApp.beginInstanceAuthorization {name, api_token}, (error, applicationInstance) ->
          #   done(error)

          # STEP 2
          # instance_id comes from an email
          instance_id = 'iGgjgWpsUtg5LT1PmZd1Y7YR-pQ3WKn5VAQcYNC04PA'
          defltApp.finishInstanceAuthorization {api_token, instance_id}
          defaultApp = defltApp; applications = apps
          done(error)
  

  describe 'application.authorizeInstance', ->
    it 'should authorize client as an application instance', (done) ->
      # lack of error proves that the authorization was successful
      defaultApp.users (error, users) ->
        expect(error).to.not.exist
        done(error)

  describe 'application.users', ->
    it 'should return a users object with a collection property', (done) ->
      defaultApp.users (error, users) ->
        expect(users).to.be.an.instanceof(Users)
        expect(users).to.have.property('collection')
        done(error)

  describe 'application.rules', ->
    # rules does not have a .list method
    it 'should return a rules object', ->
      rules = defaultApp.rules()
      expect(rules).to.be.an.instanceof(Rules)
      

describe 'Applications', ->
  client = developer = applications = ''
  name = "newApp#{Date.now()}"

  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.developers.create newDevCreds(), (error, dev) ->
        dev.applications (error, apps) ->
          client = cli; developer = dev; applications = apps
          done(error)

  it 'should memoize applications on the developer', ->
    expect(developer).to.have.a.property('_applications')


  describe.only 'applications.create', ->

    it 'should create a new Application Object', (done) ->  
      applications.create {name}, (error, application) ->
        expect(application).to.be.an.instanceof(Application)
        done(error)

    it 'should add new application to developer._applications.collection', ->
      expect(developer._applications.collection).to.have.property(name)

  # skipping because it takes too long
  describe.skip 'applications.refresh', ->
    it 'should return applications object with new application', (done) ->
      applications.refresh (error, applications) ->
        expect(applications.collection).to.have.property(name)
        done(error)
