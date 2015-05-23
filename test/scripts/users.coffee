Round = require('../../src')
Devices = require('../../src/resources/devices')
expect = require('chai').expect
credentials = require('../data/credentials')
devCreds = credentials.developer
url = credentials.url



describe 'Users Resource', ->
  client =  application = null
  before (done) ->
    Round.client {url}, (error, cli) ->
      {api_token, admin_token} = devCreds
      cli.authenticate_application {api_token, admin_token}, (error, app) ->
        client = cli; application = app
        done(error)


  describe 'User', ->
    user = null
    before (done) ->
      application.users (error, usrs) ->
        user = usrs.get(0)
        done(error)

    describe 'user.devices', ->
      it 'should return a Devices object', (done) ->
        user.devices (error, devices) ->
          console.log error, devices
          expect(devices).to.be.an.instanceof(Devices)
          done(error)



  describe 'Users', ->
    describe 'users.create', ->
      it 'should return an object with a device_token prop', (done) ->
        client.users.create({
          first_name: 'bez',
          last_name: 'reyhan',
          email: "bez#{Date.now()}@gem.co",
          device_name: 'devy',
          passphrase: 'password'
        }, (error, data) ->
          expect(data).to.have.property('device_token')
          expect(data.device_token).to.exist
          done(error)
        )



