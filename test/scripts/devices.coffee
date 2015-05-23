Round = require '../../src'
Devices = require '../../src/resources/devices'
expect = require('chai').expect
credentials = require '../data/credentials'
devCreds = credentials.developer
url = credentials.url



describe 'Applications Resource', ->
  client =  application = users = devices = null
  before (done) ->
    Round.client {url}, (error, cli) ->
      {api_token, admin_token} = devCreds
      cli.authenticate_application {api_token, admin_token}, (error, app) ->
        app.users (error, usrs) ->
          user = usrs.get('bez@gem.co')
          user.devices (error, devcs) ->
            client = cli; application = app; users = usrs; devices = devcs
            done(error)


  describe 'devices.create', ->
    it 'should return a an object with a device_token and mfa_uri', (done) ->
      devices.create {name: "hey", redirect_uri: 'http://google.com'}, (error, data) ->
        expect(data).to.have.a.property('device_token')
        expect(data).to.have.a.property('mfa_uri')
        done()