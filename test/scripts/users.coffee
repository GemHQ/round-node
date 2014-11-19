
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
{pubkey, privkey, newDevCreds, newUserContent} = credentials

# NOTE: EMAIL MUST BE RESET WHEN DATABASE RESETS
existingDevCreds = {email: 'js-test-1415675506694@mail.com', pubkey, privkey }


describe 'User Resource', ->
  client = developer = user = applications = authenticateDeviceCreds = ''

  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        cli.users.create newUserContent(), (error, usr) ->
          dev.applications (error, apps) ->
            client = cli; developer = dev; user = usr; applications = apps

            # NOTE: ALL PROPERTIES NEED TO BE RESET WHEN DB IS RESET
            # NOTE: USER_TOKEN AND USER_URL NEED BE TAKEN FROM A 
            # NEW USER, WITH EMAIL: 'bez@gem.co'
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

    describe 'user.wallets', ->
      it 'should memoize and return a wrapped Wallet object', ->
        userWallets = user.wallets()
        expect(userWallets).to.be.an.instanceof(Wallets)
        expect(user._wallets).to.deep.equal(userWallets)

    describe 'wallets.create', ->
      it 'should create and return a Wallet', (done) ->
        wallet = data.wallet
        wallet.name = "newwallet#{Date.now()}"
        userWallets = user.wallets()
        userWallets.create wallet, (error, wallet) ->
          expect(wallet).to.be.an.instanceof(Wallet)
          done(error)

    describe 'wallet.rules', ->
      it 'should return a Rules object', (done) ->
        wallet = data.wallet
        wallet.name = "newwallet#{Date.now()}"
        userWallets = user.wallets()
        userWallets.create wallet, (error, wallet) ->
          accountUrl = wallet.resource().accounts.url
          expect(wallet.rules()).to.be.an.instanceof(Rules)
          done(error)

    describe 'client.account', ->
      it 'should return an Account object', (done) ->
        wallet = data.wallet
        wallet.name = "newwallet#{Date.now()}"
        userWallets = user.wallets()
        userWallets.create wallet, (error, wallet) ->
          accountUrl = wallet.resource().accounts.url
          account = client.account accountUrl
          expect(account).to.be.an.instanceof(Account)
          done(error)

    describe 'client.wallet', ->
      it 'should return a Wallet object', (done) ->
        wallet = data.wallet
        wallet.name = "newwallet#{Date.now()}"
        userWallets = user.wallets()
        userWallets.create wallet, (error, wallet) ->
          walletUrl = wallet.resource().url
          client.wallet walletUrl, (error, wallet) ->
            expect(wallet).to.be.an.instanceof(Wallet)
            expect(wallet.resource().url).to.equal(walletUrl)
            done(error)
