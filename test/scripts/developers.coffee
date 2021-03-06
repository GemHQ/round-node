Round = require '../../src'
Developer = require '../../src/resources/developer'
Applications = require '../../src/resources/applications'
Application = require '../../src/resources/application'

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds, existingDevCreds, genKeys} = credentials

url = 'http://localhost:8999'
# url = "https://api.gem.co"
# url = "https://api-sandbox.gem.co"

describe 'Developer Resource', ->
  client = developer = ''
  before (done) ->
    Round.client {url}, (error, cli) ->
      newDevCreds (creds) ->
        cli.developers.create creds, (error, dev) ->
          client = cli; developer = dev; done(error)


  describe.only 'developers.create', ->
    it 'should return a developer object', ->
      console.log developer.resource().applications
      expect(developer).to.be.an.instanceof(Developer)

    it 'should authorize if privkey is provided', (done) ->
      developerScheme = client.patchboard().context.schemes['Gem-Developer']
      expect(developerScheme).to.have.a.property('credentials')
      # proves that client is authorized as a developer
      client.resources().developers.get (error, developerResource) ->
        expect(developerResource).to.deep.equal(developer.resource())
        done(error)


  describe 'developer.applications', ->
    applications = ''
    
    before (done) ->
      developer.applications (error, apps) ->
        console.log apps.get()
        applications = apps
        done(error)

    it 'should return an Applications object', ->
      expect(applications).to.be.an.instanceof(Applications)

    it "Applications.collection should have a 'default' Application object", ->
      expect(applications.get('default')).to.exist
      expect(applications.get('default')).to.be.an.instanceof(Application)

    it 'should cache the applications object on the developer', ->
      expect(developer._applications).to.deep.equal(applications)


  describe 'developer.update', (done) ->

    updatedDeveloper = ''
    newEmail = "thenewemail#{Date.now()}@mail.com"

    before (done) ->
      genKeys (keys) ->
        {priv, pub} = keys
        developer.update {email: newEmail, privkey: priv, pubkey: pub}, (error, updatedDev) ->
          updatedDeveloper = updatedDev
          done(error)

    it 'should return a Developer object', ->
      expect(updatedDeveloper).to.be.an.instanceof(Developer)

    it 'should update the developer with the new content', ->
      expect(updatedDeveloper.resource().email).to.equal(newEmail)

    it 'should memoize the updated developer', ->
      expect(client.developer()).to.deep.equal(updatedDeveloper)

    it 'should authorize the client with updated credentials', (done) ->
      client.resources().developers.get (error, developerResource) ->
        expect(developerResource).to.deep.equal(updatedDeveloper.resource())
        done(error)


describe 'Developer Errors', ->
  it "should throw 'Missing Credential Error'", (done) ->
    Round.client {url}, (error, client) ->
      client.developers.create {}, (error, dev) ->
        expect(error).to.exist
        done()


# SHOULD ONLY BE USED WHEN CREATING BEZ@GEM.CO FOR THE FIRST TIME
describe.skip 'Developer Resource', ->
  it 'should create a dev acccount for bez@gem.co', (done) ->
    Round.client {url}, (error, cli) ->
      cli.developers.create existingDevCreds, (error, dev) ->
        expect(dev).to.be.an.instanceof(Developer)
        done(error)



