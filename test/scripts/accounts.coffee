Round = require '../../src'
Account = require '../../src/resources/account'
Addresses = require '../../src/resources/addresses'
Transactions = require '../../src/resources/transactions'

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds, newUserContent, existingDevCreds, authenticateDeviceCreds} = credentials


describe 'Accounts Resource', ->
  client = developer = user = applications = accounts = account = wallet = ''

  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        dev.applications (error, apps) ->
          client = cli; developer = dev; applications = apps;

          client.authenticateDevice authenticateDeviceCreds(applications), (error, usr) ->
            user = usr
            user.wallets (error, wallets) ->
              wallet = wallets.collection.default
              wallet.accounts (error, accnts) ->
                accounts = accnts
                account = accounts.collection.default
                done(error)

  # Note: We may be removing client.account
  describe 'client.account', ->
    `var account`
    it 'should return an Account object', ->
      accountUrl = wallet.resource().accounts.url
      account = client.account accountUrl
      expect(account).to.be.an.instanceof(Account)

  # skipping because it creates a wallet for the same
  # user and therefor makes other calls really slow
  describe.skip 'accounts.create', ->
    `var account, name`

    before (done) ->
      name = "newAccount#{Date.now()}"
      accounts.create {name}, (error, accnt) ->
        account = accnt
        done(error)
  
    it 'should create a new Account object', () ->
      expect(account).to.be.an.instanceof(Account)

    it 'should memoize the new account', () ->
      wallet.accounts (error, accounts) ->
        expect(wallet._accounts.collection).to.have.a.property(name)


  # currently receiving a 401, not sure why
  describe.skip 'account.update', ->
    it 'should update the account resource', (done) ->
      account.resource().update {name}, (error, accountResource) ->
        done()


  describe 'account.addresses', ->
    addresses = ''

    before (done) ->
      account.addresses (error, addrs) ->
        addresses = addrs
        done(error)

    it 'should return an Addresses object', ->
      expect(addresses).to.be.an.instanceof(Addresses)

    it 'should have a collection property', ->
      expect(addresses).to.have.a.property('collection')


  # account.resource().transactions returns a function
  # not a resource. Could be a bug in Patchboard
  describe.skip 'account.transactions', ->
    it 'should return a transactions object', (done) ->
      done()

  # not built yet
  describe.skip 'account.payments', ->
    it 'should return a payments object', (done) ->
      account.resource().payments.list (error, payment) ->
        done()

  # not built yet
  describe.skip 'account.pay', ->
    it 'should make payment to the payees', ->






