Round = require '../../src'
Account = require '../../src/resources/account'

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds, newUserContent} = credentials
existingDevCreds = {email: 'js-test-1415675506694@mail.com', pubkey, privkey }

describe 'Account Resource', ->
  client = developer = user = applications = account = authenticateDeviceCreds = wallet = ''

  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        dev.applications (error, apps) ->
          client = cli; developer = dev; applications = apps;
          # NOTE: ALL PROPERTIES NEED TO BE RESET WHEN DB IS RESET
          # NOTE: USER_TOKEN AND USER_URL NEED BE TAKEN FROM A
          # NEW USER, WITH EMAIL: 'bez@gem.co'
          authenticateDeviceCreds = {
            api_token: applications.collection.default.api_token,
            app_url: applications.collection.default.url,
            key: 'otp.qtC227V9269iaDN-rmBsdw',
            secret: 'LNXb4PF9y8RryZeDfs1ABw',
            device_id: 'newdeviceid1415910373357',
            user_token: 'iTm14NBmJkvUnLkR0v-GktkDH1gFqOwMfdyHFTwzPjE',
            user_url: 'http://localhost:8999/users/1Z70SwJud0nraR6EkNiS8g',
            name: 'newapp'
          }

          client.authenticateDevice authenticateDeviceCreds, (error, usr) ->
            user = usr

            wallet = data.wallet
            wallet.name = "newwallet#{Date.now()}"
            userWallets = user.wallets()
            userWallets.create wallet, (error, walletObj) ->
              wallet = walletObj
              accountUrl = wallet.resource().accounts.url
              account = client.account accountUrl
              done(error)

  describe 'client.account', ->
    it 'should return an Account object', (done) ->
      expect(account).to.be.an.instanceof(Account)
      done()

  describe 'account.create', ->
    newAccount = ''

    before (done) ->
      name = "newAccount"
      wallet.accounts().create {name}, (error, account) ->
        newAccount = account
        done(error)

    it 'should create a new Account object', () ->
      expect(newAccount).to.be.an.instanceof(Account)

    it 'should memoize the new account', () ->
      console.log wallet.accounts()
     



