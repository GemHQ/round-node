Round = require '../../src'
Devices = require '../../src/resources/devices'
expect = require('chai').expect
credentials = require '../data/credentials'
devCreds = credentials.developer
url = credentials.url



describe 'Applications Resource', ->
  client =  application = users = null
  before (done) ->
    Round.client {url}, (error, cli) ->
      {api_token, admin_token} = devCreds
      cli.authenticate_application {api_token, admin_token}, (error, app) ->
        app.users (error, usrs) ->
          client = cli; application = app; users = usrs
          done(error)


  describe 'user.devices', ->
    it 'should return a Devices object', (done) ->
      user = users.get(0)
      user.devices (error, devices) ->
        expect(devices).to.be.an.instanceof(Devices)
        done(error)


