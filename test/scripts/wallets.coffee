Round = require '../../src'
Wallet = require '../../src/resources/wallet'
Wallets = require '../../src/resources/wallets'
Rules = require '../../src/resources/rules'

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds, newUserContent} = credentials
existingDevCreds = {email: 'js-test-1415675506694@mail.com', pubkey, privkey }

describe 'Wallet Resource', ->
  client = developer = user = applications = authenticateDeviceCreds = ''

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
            done(error)

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
