
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


describe.only 'User Resource', ->
  client = developer = user = applications = ''

  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        cli.users.create newUserContent(), (error, usr) ->
          dev.applications (error, apps) ->
            client = cli; developer = dev; user = usr; applications = apps
            done(error)

  describe 'client.users.create', ->
    it 'should create a user object', (done) ->
      expect(user.resource()).to.have.a.property('email') 
      done()

  describe 'user.beginDeviceAuthorization', ->
    it 'should memoize device_name and device_id', (done) ->
      device_id = "newdeviceid#{Date.now()}"
      credentials = { name: 'thecooldevice', device_id }
      user.beginDeviceAuthorization credentials, (key) ->
        expect(key.substr(0,3)).to.equal('otp')
        expect(user.currentDeviceName).to.equal('thecooldevice')
        expect(user.currentDeviceId).to.equal(device_id)
        done()

  describe "Authenticated User", ->
    user = ''
    before (done) ->
      client.authenticateDevice authenticateDeviceCreds(applications), (error, usr) ->
        user = usr
        done(error)

    describe 'client.authenticateDevice', ->
      it 'return an authenticated user', ->
        expect(user).to.be.an.instanceof(User)
      # Note: Proceeding lines are commented for automation purposes.
      # Note: To test fully, you must run the test in 2 steps
        # # FIRST
        # client.patchboard().context.schemes['Gem-OOB-OTP']['credentials'] = 'data="none"'
        # u = client.resources().user_query {email: 'bez@gem.co'}
        # device_id =  "newdeviceid#{Date.now()}"
        # console.log 'device_id ------------------------------'
        # console.log device_id
        # u.authorize_device {name: 'newapp', device_id}, (error, data) ->
        #   regx = /"(.*)"/
        #   response = error.response.headers['www-authenticate']
        #   matches = regx.exec response
        #   key = matches[1]
        #   console.log key
        #   done()

      # Note: proceeding lines are commented inorder to automate tests.
      # SECOND
        # client.authenticateOTP {api_token, key, secret}
        # u = client.resources().user_query {email: 'bez@gem.co'}
        # u.authorize_device {name, device_id}, (error, user) ->
          # client.authenticateDevice authenticateDeviceCreds, (error, user) ->
          #   expect(user).to.be.an.instanceof(User)
          #   done(error)

  # Skipping because it takes to long to load
  # Must clear out bez@gem.co wallets
  describe.skip 'user.wallets', ->
    it 'should memoize and return a wrapped Wallet object', (done) ->
      user.wallets (error, wallets) ->
        expect(wallets).to.be.an.instanceof(Wallets)
        expect(user._wallets).to.deep.equal(wallets)
        done(error)