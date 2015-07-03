Round = require '../../src'
Devices = require '../../src/resources/devices'
expect = require('chai').expect
credentials = require '../data/credentials'
devCreds = credentials.developer
userCreds = credentials.user
url = credentials.url



describe 'Applications Resource', ->
  client =  devices = null
  before ->
    Round.client {url}
    .then (cli) -> 
      client = cli
      {api_token} = devCreds
      client.authenticate_identify {api_token}
      client.user {email: 'bez+1435873095814@gem.co'}
    .then (user) -> user.devices()
    .then (dvcs) -> devices = dvcs
    .catch (error) -> error


  describe 'devices.create', ->
    it 'should return a an object with a device_token and mfa_uri', (done) ->
      devices.create({name: "newDevice#{Date.now()}"})
      .then (data) ->
        console.log data
        expect(data).to.have.a.property('device_token')
        expect(data).to.have.a.property('mfa_uri')
        done()
      .catch (error) -> done(error)