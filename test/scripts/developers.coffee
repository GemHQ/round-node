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
{pubkey, privkey, newDevCreds} = credentials


describe 'Developer Resource', ->
  client = developer = ''
  
  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.developers.create newDevCreds(), (error, dev) ->
        client = cli; developer = dev; done(error)

  describe 'developers.create', ->
    it 'should return a developer object (and authorize if privkey is provided)', (done) ->
      expect(developer).to.be.an.instanceof(Developer)
      developerScheme = client.patchboard().context.schemes['Gem-Developer']
      expect(developerScheme).to.have.a.property('credentials')
      # proves that client is authorized as a developer
      client.resources().developers.get (error, developerResource) ->
        expect(developerResource).to.deep.equal(developer.resource())
        done(error)


  describe 'developer.applications(callback)', ->
    applications = ''
    before (done) ->
      developer.applications (error, apps) ->
        applications = apps
        done(error)

    it 'should return an Applications object', ->
      expect(applications).to.be.an.instanceof(Applications)

    it "Applications object should have a 'default' Application object", ->
      expect(applications).to.have.a.property('default')
      expect(applications.default).to.be.an.instanceof(Application)


  describe 'developer.update', ->
    updatedDeveloper = ''
    newEmail = "thenewemail#{Date.now()}@mail.com"
    before (done) ->
      developer.update {email: newEmail, privkey}, (error, updatedDev) ->
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