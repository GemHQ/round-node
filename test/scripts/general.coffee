Round = require '../../src'
Developer = require '../../src/resources/developer'
Developers = require '../../src/resources/developers'
Applications = require '../../src/resources/applications'
Users = require '../../src/resources/users'
User = require '../../src/resources/user'
Wallets = require '../../src/resources/wallets'
Wallet = require '../../src/resources/wallet'
expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
keys = require '../data/keys'
pubkey =  keys.pubkey
privkey = keys.privkey

email = () -> "js-test-#{Date.now()}@mail.com"
existingDevCreds = {email: 'js-test-1415675506694@mail.com', pubkey, privkey }
existingDevApiToken = 'HTqU6tkpygsTWITOEyfwsEMFXX8PjgKDt7kL1gZVW4g'
newDevCreds = -> {email: email(), pubkey, privkey }
newUserContent = -> {email: "js-test-#{Date.now()}@mail.com", wallet: data.wallet }
newBezContent = {email: "bez@gem.co", wallet: data.wallet }


describe 'Round.client', ->
  it 'should create a new client with a property of patchboard', (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, client) ->
      client.developers.create newDevCreds(), (error, developer) ->
        done(error)

describe 'Client Methods', ->
  
  describe 'Round.client', ->
    it 'should create a new client with a property of patchboard', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        expect(client).to.have.property 'patchboard'
        expect(client.patchboard()).to.have.property 'resources'
        done(error)

  describe 'client.authenticateDeveloper', ->
    it 'should authenticate a client as a Gem-Developer & memoize _developer on the client ', (done) ->  
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        client.authenticateDeveloper existingDevCreds, (error, developer) ->
          expect(client).to.have.property('_developer')
          done(error)

  # Note:
  # describe.skip 'client.authenticateDevice()', ->
    # this test can be found in the User tests

  describe 'client.developer()', ->
    it 'should throw an error if a developer has NOT been authenticated', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        expect(client.developer).to.throw('You have not yet authenticated as a developer')
        done(error)

    it 'should return a devloper object if previously authorized', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        client.authenticateDeveloper existingDevCreds, (error, developer) ->
          expect(developer).to.be.an.instanceof(Developer)
          done(error)

  describe 'client.developers', ->
    it 'should return an instance of developers', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        expect(client.developers).to.be.an.instanceof(Developers)
        done(error)

  describe 'client.applications', ->
    it 'should return an instance of Applications', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        expect(client.applications).to.be.an.instanceof(Applications)
        done(error)

  describe 'client.users', ->
    it 'should return an instance of users', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        expect(client.users).to.be.an.instanceof(Users)
        done(error)

  # Note:
  # describe.skip 'client.user(callback)', ->
    # This is tested implicitely through client.authenticateDevice test


describe 'Developer Resource', ->
  client = developer = ''
  
  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.developers.create newDevCreds(), (error, dev) ->
        client = cli; developer = dev; done(error)

  describe 'client.developers.create', ->
    it 'should return a developer object (and authorize if privkey is provided)', (done) ->
      expect(developer).to.be.an.instanceof(Developer)
      # proves that client is authorized as a developer
      client.resources().developers.get (error, developer) ->
        done(error)

  describe 'developer.applications(callback)', ->
    it 'should return an instance of Applications', (done) ->
      developer.applications (error, applications) ->
        expect(applications).to.be.an.instanceof Applications
        done(error)

  describe 'developer.update {email: ...}', ->
    it 'should persist updated data, reauthorize with new credentials, memoize and return updated developer', (done) ->
      newEmail = "thenewemail#{Date.now()}@mail.com"
      developer.update {email: newEmail, privkey}, (error, updatedDeveloper) ->
        expect(updatedDeveloper).to.be.an.instanceof(Developer)
        expect(updatedDeveloper.resource().email).to.equal(newEmail)
        expect(client.developer()).to.deep.equal(updatedDeveloper)
        # proves that updatedDeveloper has been authorized
        client.resources().developers.get (error, developer) ->
          done(error)



describe 'User Resource', ->
  client = developer = user = applications = authenticateDeviceCreds = ''

  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        cli.users.create newUserContent(), (error, usr) ->
          dev.applications (error, apps) ->
            client = cli; developer = dev; user = usr; applications = apps

            authenticateDeviceCreds = {
              api_token: applications.default.api_token,
              app_url: applications.default.url,
              key: 'otp.qtC227V9269iaDN-rmBsdw',
              secret: 'LNXb4PF9y8RryZeDfs1ABw',
              device_id: 'newdeviceid1415910373357',
              user_token: 'iTm14NBmJkvUnLkR0v-GktkDH1gFqOwMfdyHFTwzPjE',
              user_url: 'http://localhost:8999/users/1Z70SwJud0nraR6EkNiS8g',
              name: 'newapp'
            }
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
      client.authenticateDevice authenticateDeviceCreds, (error, usr) ->
        user = usr
        done()

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

      # Note: next 3 lines are commented inorder to automate tests.
      # SECOND
        # client.authenticateOTP {api_token, key, secret}
        # u = client.resources().user_query {email: 'bez@gem.co'}
        # u.authorize_device {name, device_id}, (error, user) ->
          # client.authenticateDevice authenticateDeviceCreds, (error, user) ->
          #   expect(user).to.be.an.instanceof(User)
          #   done(error)

    describe 'user.wallets', ->
      it 'should memoize and return a wrapped Wallet object', ->
        userWallets = user.wallets()
        expect(userWallets).to.be.an.instanceof(Wallets)
        expect(user._wallets).to.deep.equal(userWallets)

    describe.skip 'user.update', ->
      # Fix: requires user auth which hasn't been build yet
      it 'should memoize and return an updated User object', (done) ->
        user.update

    describe 'wallets.create', ->
      it 'should create and return a Wallet', (done) ->
        wallet = data.wallet
        wallet.name = "newwallet#{Date.now()}"
        userWallets = user.wallets()
        userWallets.create wallet, (error, wallet) ->
          expect(wallet).to.be.an.instanceof(Wallet)
          done(error)

