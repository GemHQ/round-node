
Round = require '../../src'
creds = require('../data/credentials')
developersCreds = creds.developer
url = creds.url
Application = require('../../src/resources/application')
chai = require('chai')
chai.use(require('chai-as-promised'))
expect = chai.expect



describe 'Client Methods', ->

  client = null
  before (done) ->
    Round.client {url}
    .then (cli) -> client = cli; done()
    .catch (error) -> throw error

  describe 'Round.client', ->
    it 'should create a new client with a property of patchboard', ->
      expect(client).to.have.property 'patchboard'
      expect(client.patchboard).to.have.property 'resources'
      expect(client.patchboard).to.have.property 'context'


  describe "client.authenticate_application", ->
    it 'should return an Application object', ->
      application = client.authenticate_application(developersCreds)
      expect(application).to.eventually.be.an.instanceof(Application)


