Round = require '../../src'
Account = require '../../src/resources/account'
Addresses = require '../../src/resources/addresses'
Transactions = require '../../src/resources/transactions'
Wallet = require '../../src/resources/wallet'
Payment = require '../../src/resources/payment'
PaymentGenerator = require '../../src/resources/payment_generator'

paymentResource = require('../data/transaction.json').payment

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


  describe.only 'accounts', ->
    it 'should have a wallet property', ->
      expect(accounts).to.have.a.property('wallet')
      expect(accounts.wallet).to.be.an.instanceof(Wallet)


  describe 'account.payments', ->
    payments = null
    
    before ->
      payments = account.payments()

    it 'should return an instance of PaymentGenerator ', ->
      expect(payments).to.be.an.instanceof(PaymentGenerator)

    it 'should memoize the instance on @_payments', ->
      expect(account._payments).to.deep.equal(payments)


  # Skipping because we will run out of coins
  describe.skip 'account.pay', ->
    
    it 'should not throw an error (i.e. make a successful tx)', (done) ->
      account.wallet.unlock("passphrase")
      payees = [{amount: 1000, address: 'mrkGJWekqbpyrVdDbfwjzmizxA86cgP8T8'}]

      account.pay payees, (error, data) ->
        expect(error).to.not.exist
        done(error)
        

  describe 'account.wallet', ->
    it 'should reference the wallet it belongs to', ->
      expect(account.wallet).to.be.instanceof(Wallet)


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
    newAccount = accountName = null

    before (done) ->
      accountName = "on_account_of_who4"
      accounts.create {name: accountName}, (error, account) ->
        newAccount = account
        done(error)
  
    it 'should create a new Account object', () ->
      expect(newAccount).to.be.an.instanceof(Account)

    it 'should memoize the new account', () ->
      wallet.accounts (error, accounts) ->
        expect(wallet._accounts.collection).to.have.a.property(accountName)


  # currently receiving a 401, not sure why
  describe.skip 'account.update', ->
    it 'should update the account resource', (done) ->
      name = "newname#{Date.now()}"
      acnt = accounts.collection.cool_account
      acnt.resource().update {name}, (error, accountResource) ->
        console.log error, accountResource
        done()


  describe 'account.addresses', ->
    addresses = ''

    before (done) ->
      account.addresses (error, addrs) ->
        addresses = addrs
        console.log addresses
        done(error)

    it 'should return an Addresses object', ->
      expect(addresses).to.be.an.instanceof(Addresses)

    it 'collection keys should not be undefined', ->
      expect(addresses.collection).to.not.have.a.property('undefined')

    it 'should cache the addresses object on the account', ->
      expect(account._addresses).to.deep.equal(addresses)



  # account.resource().transactions returns a function
  # not a resource. Could be a bug in Patchboard
  describe 'account.transactions', ->
    it 'should return a transactions object', (done) ->
      account.resource().get (err, res) ->
        console.log res.trans
        done()
