Round = require '../../src'
Account = require '../../src/resources/account'

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds, newUserContent, existingDevCreds, authenticateDeviceCreds} = credentials

describe 'Account Resource', ->
  client = developer = user = applications = account = wallet = ''

  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        dev.applications (error, apps) ->
          client = cli; developer = dev; applications = apps;

          client.authenticateDevice authenticateDeviceCreds(applications), (error, usr) ->
            user = usr
            wallet = data.wallet
            wallet.name = "newwallet#{Date.now()}"
            user.wallets (error, wallets) ->
              wallets.create wallet, (error, walletObj) ->
                wallet = walletObj
                accountUrl = wallet.resource().accounts.url
                account = client.account accountUrl
                done(error)

  describe 'client.account', ->
    it 'should return an Account object', (done) ->
      expect(account).to.be.an.instanceof(Account)
      done()

  describe 'accounts.create', ->
    newAccount = ''

    before (done) ->
      name = "newAccount"
      wallet.accounts (error, accounts) ->
        accounts.create {name}, (error, account) ->
          newAccount = account
          done(error)

    it 'should create a new Account object', () ->
      expect(newAccount).to.be.an.instanceof(Account)

    it.skip 'should memoize the new account', () ->
      # currently doesn't add account to a collections obj
      console.log wallet.accounts()
     




