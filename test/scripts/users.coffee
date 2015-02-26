
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
{pubkey, privkey, newDevCreds, newUserContent, existingDevCreds, authenticateDeviceCreds, authenticateDeviceCredsStaging, authenticateDeviceCredsProd } = credentials

# url = 'http://localhost:8999'
url = "https://api.gem.co"
# url = "https://api-sandbox.gem.co"

if url == "https://api-sandbox.gem.co"
  authenticateDeviceCreds = authenticateDeviceCredsStaging
if url == "https://api.gem.co"
  authenticateDeviceCreds = authenticateDeviceCredsProd


describe 'User Resource', ->
  client = developer = user = applications = ''

  before (done) ->
    Round.client {url}, (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        dev.applications (error, apps) ->
          client = cli; developer = dev; applications = apps
          done(error)


  describe.skip 'client.users.create', ->
    it 'should create a user object', (done) ->
      email = "js-test-#{Date.now()}@mail.com"
      # email = "bez@gem.co"
      passphrase = 'passphrase'
      client.users.create {email, passphrase}, (error, user_and_backup_seed) ->
        {user, backup_seed} = user_and_backup_seed
        expect(user.resource()).to.have.a.property('email')
        done()


  # being skipped because it sends an email
  describe.skip 'user.beginDeviceAuthorization', ->
    it 'should recive a key', (done) ->
      device_id = "newdeviceid#{Date.now()}"
      email = user.resource().email
      api_token = applications.get('default').api_token
      credentials = { name: 'thecooldevice', device_id, email, api_token }
      client.beginDeviceAuthorization credentials, (error, key) ->
        expect(key.substr(0,3)).to.equal('otp')
        done()


  describe.skip 'client.authenticateDevice', ->
    it 'return an authenticated user', (done) ->
    # Note: Proceeding lines are commented for automation purposes.
    # Note: To test fully, you must run the test in 2 steps
      # FIRST
      # {name, email, api_token} = authenticateDeviceCreds(applications)
      # device_id =  "newdeviceid#{Date.now()}"
      # console.log 'device_id ------------------------------'
      # console.log device_id
      # client.beginDeviceAuthorization {api_token, email, device_id, name}, (error, key) ->
      #   console.log "key -------------------------------"
      #   console.log key
      #   done(error)


    # Note: proceeding lines are commented inorder to automate tests.
    # SECOND
      client.completeDeviceAuthorization authenticateDeviceCreds(applications), (error, user) ->
        # console.log user.resource().url
        console.log user.resource().user_token
        done(error)


  # should only be run if at one point a user has gone through
  # the 2-step process listed above
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


    describe 'client.user', ->
      it 'should return an instance of user when provided an email', (done) ->
        client.user {email: 'bez@gem.co'}, (error, user) ->
          expect(user).to.be.an.instanceof(User)
          done(error)

    # Requires device auth
    # Skipping because it takes to long to load
    # Must clear out bez@gem.co wallets
    describe 'user.wallets', ->
      it 'should memoize and return a wrapped Wallet object', (done) ->
        user.wallets (error, wallets) ->
          expect(error).to.not.exist
          expect(wallets).to.be.an.instanceof(Wallets)
          expect(user._wallets).to.deep.equal(wallets)
          done(error)


  