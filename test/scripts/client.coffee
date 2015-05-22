
Round = require '../../src'
creds = require('../data/credentials')
developersCreds = creds.developer
url = creds.url
Application = require('../../src/resources/application')
expect = require('chai').expect


describe 'Client Methods', ->

  client = null
  before (done) ->
    Round.client {url}, (error, cli) ->
      client = cli
      done(error)

  describe 'Round.client', ->
    it 'should create a new client with a property of patchboard', ->
      expect(client).to.have.property 'patchboard'
      expect(client.patchboard).to.have.property 'resources'
      expect(client.patchboard).to.have.property 'context'

    it 'should default to bitcoin_testnet if network is not provided', ->
      expect(client.network).to.equal('bitcoin_testnet')


  describe "client.authenticate_application", ->
    it 'should return an Application object', (done) ->
      client.authenticate_application developersCreds, (error, application) ->
        expect(application).to.be.an.instanceof(Application)
        done(error)


