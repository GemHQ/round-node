Round = require('../../src')
Devices = require('../../src/resources/devices')
Wallet = require('../../src/resources/wallet')
chai = require('chai')
chai.use(require('chai-as-promised'))
expect = chai.expect
credentials = require('../data/credentials')
devCreds = credentials.developer
userCreds = credentials.user
url = credentials.url



describe 'Users Resource', ->
  client =  application = null
  before ->
    Round.client {url}
    .then (cli) -> 
      client = cli
      {api_token, admin_token} = devCreds
      client.authenticate_application {api_token, admin_token}
    .then (app) -> application = app
    .catch (error) -> error


  describe 'User', ->
    user = null
    before ->
      application.users().then (usrs) ->
        user = usrs.get(userCreds.email)

    describe 'user.devices', ->
      it 'should return a Devices object', ->
        expect(user.devices()).to.eventually.be.an.instanceof(Devices)

    describe 'user.wallet', ->
      it 'should return a wallet object', (done) ->
        user.wallet()
        .then (wallet) ->
          expect(wallet).to.be.an.instanceof(Wallet); done()
        .catch (error) -> done(error)



  describe 'Users', ->
    describe.only 'users.create', ->
      it 'should return a device_token', (done) ->
        client.users.create({
          first_name: 'bez',
          last_name: 'reyhan',
          email: "bez+#{Date.now()}@gem.co",
          device_name: 'devy',
          passphrase: 'password'
        })
        .then (device_token) ->
          console.log device_token
          expect(device_token).to.exist
          done()
        .catch (error) -> done(error)