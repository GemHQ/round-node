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
{pubkey, privkey, newDevCreds, newUserContent, existingDevCreds} = credentials


describe 'Applications Resource', ->
  client = defaultApp = applications = ''
  before (done) ->
    Round.client {url: 'http://localhost:8999'}, (error, cli) ->
      client = cli
      # Note: depends on their already existing a developer account for bez@gem.co
      client.authenticateDeveloper existingDevCreds, (error, developer) ->
        developer.applications (error, apps) ->
          defltApp = apps.get('default')
          {api_token, url} = defltApp
          
          # # STEP 1
          # name = "MainAppInstance"
          # defltApp.authorizeInstance {name}, (error, applicationInstance) ->
          #   done(error)

          # STEP 2
          # instance_id comes from an email
          instance_id = 'nxSzPywsExPmebVMvEZX5lh5oiwXIqVryav1qDeYuyA'
          client.authenticateApplication {api_token, instance_id, app_url: url}, (error, app) ->
            defaultApp = app; applications = apps
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
        expect(users).to.have.property('_collection')
        done(error)


  describe 'application.rules', ->
    # rules does not have a .list method
    it 'should return a rules object', ->
      rules = defaultApp.rules()
      expect(rules).to.be.an.instanceof(Rules)
      

describe 'Applications', ->
  client = developer = applications = application = ''
  name = "newApp#{Date.now()}"

  before (done) ->
    Round.client {url: 'http://localhost:8999'}, (error, cli) ->
      newDevCreds (creds) ->
        cli.developers.create creds, (error, dev) ->
          dev.applications (error, apps) ->
            apps.create {name}, (error, app) ->
              client = cli; developer = dev; applications = apps; application = app
              done(error)

  it 'should memoize applications on the developer', ->
    expect(developer).to.have.a.property('_applications')


  describe 'applications.create', ->
    it 'should create a new Application Object', ->  
      expect(application).to.be.an.instanceof(Application)


  describe 'applications.refresh', ->
    it 'should return applications object with new application', (done) ->
      applications.refresh (error, applications) ->
        expect(-> applications.get(name)).to.exist
        done(error)


  describe 'application.reset', ->
    it 'should return an application that has an updated api_token', (done) ->
      oldToken = application.api_token
      application.reset (error, updatedApp) ->
        expect(updatedApp.api_token).to.not.equal(oldToken)
        expect(updatedApp.resource().api_token).to.not.equal(oldToken)
        done(error)


  describe 'application.update', ->
    it 'should return the same app object with a new resource', (done) ->
      oldName = name
      newName = "updatedApp#{Date.now()}"
      application.update  {name: newName}, (error, updatedApp) ->
        expect(updatedApp.resource().name).to.equal(newName)
        expect(updatedApp.name).to.equal(newName)
        expect(updatedApp.name).to.equal(newName)
        expect(updatedApp.api_token).to.equal(application.api_token)
        done(error)








