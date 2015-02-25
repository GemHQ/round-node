
Round = require '../../src'
Developers = require '../../src/resources/developers'
Developer = require '../../src/resources/developer'
# Applications = require '../../src/resources/applications'
Users = require '../../src/resources/users'
User = require '../../src/resources/user'

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds} = credentials

url = 'http://localhost:8999'

describe 'Client Methods', ->
  existingDevCreds = ''
  
  before (done) ->
    Round.client {url}, (error, client) ->
      newDevCreds (creds) ->
        client.developers.create creds, (error, developer) ->
          email = developer.resource().email
          existingDevCreds = creds
          done(error)


  describe 'Round.client', ->
    it 'should create a new client with a property of patchboard', (done) ->
      Round.client {url}, (error, client) ->
        expect(client).to.have.property 'patchboard'
        expect(client.patchboard()).to.have.property 'resources'
        done(error)


  describe.only 'client.authenticateDeveloper', ->
    it 'should authenticate a client as a Gem-Developer & memoize _developer on the client ', (done) ->
      Round.client {url}, (error, client) ->
        client.authenticateDeveloper existingDevCreds, (error, developer) ->
          expect(client).to.have.property('_developer')
          done(error)


  describe 'client.developer()', ->
    it 'should throw an error if a developer has NOT been authenticated', (done) ->
      Round.client {url}, (error, client) ->
        expect(client.developer).to.throw('You have not yet authenticated as a developer')
        done(error)

    it 'should return a devloper object if previously authorized', (done) ->
      Round.client {url}, (error, client) ->
        client.authenticateDeveloper existingDevCreds, (error, developer) ->
          expect(developer).to.be.an.instanceof(Developer)
          done(error)


  describe 'client.developers', ->
    it 'should return an instance of developers', (done) ->
      Round.client {url}, (error, client) ->
        expect(client.developers).to.be.an.instanceof(Developers)
        done(error)


  describe 'client.users', ->
    it 'should return an instance of users', (done) ->
      Round.client {url}, (error, client) ->
        expect(client.users).to.be.an.instanceof(Users)
        done(error)



  # Notes:
    # describe.skip 'client.user(callback)', ->
      # This is tested implicitely through client.authenticateDevice test

    # describe 'client.account', ->
      # This is tested in Account tests because device auth is required

    # describe 'client.wallet', ->
      # This is tested in Wallet tests because device auth is required

    # describe.skip 'client.authenticateDevice()', ->
      # this test can be found in the User tests
