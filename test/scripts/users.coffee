
Round = require '../../src'
User = require '../../src/resources/user'
Wallets = require '../../src/resources/wallets'
Wallet = require '../../src/resources/wallet'
Rules = require '../../src/resources/rules'
Account = require '../../src/resources/account'

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds, newUserContent, existingDevCreds, authenticateDeviceCreds} = credentials


describe 'User Resource', ->
  client = developer = user = applications = ''

  before (done) ->
    Round.client {url: 'http://localhost:8999'}, (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        console.log error if error
        email = "js-test-#{Date.now()}@mail.com"
        passphrase = 'passphrase'
        cli.users.create {email, passphrase}, (error, user_and_multiwallet) ->
          console.log error if error
          dev.applications (error, apps) ->
            console.log error if error
            client = cli; developer = dev; applications = apps
            user = user_and_multiwallet.user
            done(error)


  describe.only 'client.users.create', ->
    it 'should create a user object', (done) ->
      expect(user.resource()).to.have.a.property('email')
      done()


  # being skipped because it sends an email
  describe.skip 'user.beginDeviceAuthorization', ->
    it 'should recive a key', (done) ->
      device_id = "newdeviceid#{Date.now()}"
      email = user.resource().email
      api_token = applications.collection.default.api_token
      credentials = { name: 'thecooldevice', device_id, email, api_token }
      client.beginDeviceAuthorization credentials, (error, key) ->
        expect(key.substr(0,3)).to.equal('otp')
        done()


  describe "Authenticated User", ->
    user = ''
    before (done) ->
      client.authenticateDevice authenticateDeviceCreds(applications), (error, usr) ->
        user = usr
        done(error)


    describe 'client.authenticateDevice', ->
      it 'return an authenticated user', (done) ->
        expect(user).to.be.an.instanceof(User)
        done()
      # # Note: Proceeding lines are commented for automation purposes.
      # # Note: To test fully, you must run the test in 2 steps
      #   # FIRST
        # api_token = applications.collection.default.api_token
        # name = "newapp"
        # email = "bez@gem.co"
        # device_id =  "newdeviceid#{Date.now()}"
        # console.log 'device_id ------------------------------'
        # console.log device_id
        # client.beginDeviceAuthorization {api_token, email, device_id, name}, (error, key) ->
        #   console.log "key -------------------------------"
        #   console.log key
        #   done(error)


      # # Note: proceeding lines are commented inorder to automate tests.
      # # SECOND
        # {api_token, key, secret, device_id, name} = authenticateDeviceCreds(applications)
        # client.completeDeviceAuthorization authenticateDeviceCreds(applications), (error, user) ->
        #   console.log user.resource().url
        #   console.log user.resource().user_token
        #   done(error)
  

    describe 'client.user', ->
      it 'should return an instance of user when provided an email', (done) ->
        client.user {email: 'bez@gem.co'}, (error, user) ->
          expect(user).to.be.an.instanceof(User)
          done(error)

    # Requires device auth
    # Skipping because it takes to long to load
    # Must clear out bez@gem.co wallets
    describe.only 'user.wallets', ->
      it 'should memoize and return a wrapped Wallet object', (done) ->
        user.wallets (error, wallets) ->
          expect(error).to.not.exist
          expect(wallets).to.be.an.instanceof(Wallets)
          expect(user._wallets).to.deep.equal(wallets)
          done(error)


  