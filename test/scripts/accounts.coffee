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

url = 'http://localhost:8999'
# url = "https://api.gem.co"
# url = "https://api-sandbox.gem.co"


describe 'Accounts Resource', ->
  client = developer = user = applications = accounts = account = wallet = ''

  before (done) ->
    Round.client {url}, (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        dev.applications (error, apps) ->
          client = cli; developer = dev; applications = apps;

          client.authenticateDevice authenticateDeviceCreds(applications), (error, usr) ->
            user = usr
            user.wallets (error, wallets) ->
              wallet = wallets.get('default')
              wallet.accounts (error, accnts) ->
                accounts = accnts
                account = accounts.get('default')
                done(error)


  describe 'accounts', ->
    it 'should have a wallet property', ->
      expect(accounts).to.have.a.property('wallet')
      expect(accounts.wallet).to.be.an.instanceof(Wallet)


  describe.skip 'account.transaction', ->
    it 'should return an instance of Transactions', (done) ->
      account.transactions (error, transactions) ->
        # console.log transactions
        # console.log transactions._modelList[4].resource().cancel (error, data) -> console.log error, data
        expect(transactions).to.be.an.instanceof(Transactions)
        done()


  describe 'account.payments', ->
    payments = null
    
    before ->
      payments = account.payments()

    it 'should return an instance of PaymentGenerator ', ->
      expect(payments).to.be.an.instanceof(PaymentGenerator)

    it 'should memoize the instance on @_payments', ->
      expect(account._payments).to.deep.equal(payments)


  # Skipping because we will run out of coins
  describe.only 'account.pay', ->
    
    it 'should not throw an error (i.e. make a successful tx)', (done) ->
      account.wallet.unlock("passphrase")
      payees = [{amount: 5430, address: 'msj42CCGruhRsFrGATiUuh25dtxYtnpbTx'}]

      account.pay {payees}, (error, data) ->
        # console.log error
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
        expect(wallet._accounts.get()).to.have.a.property(accountName)


  # skipping because it requires Gem-User auth
  describe.skip 'account.update', ->
    it 'should update the account resource', (done) ->
      name = "newname#{Date.now()}"
      acnt = accounts.get('cool_account')
      acnt.resource().update {name}, (error, accountResource) ->
        console.log error, accountResource
        done()


  describe.skip 'account.addresses', ->
    addresses = ''

    before (done) ->
      account.addresses (error, addrs) ->
        console.log addrs.get()
        addresses = addrs
        done(error)

    it 'should return an Addresses object', ->
      expect(addresses).to.be.an.instanceof(Addresses)

    it 'collection keys should not be undefined', ->
      expect(-> addresses.get('undefined')).to.throw(Error)

    it 'should cache the addresses object on the account', ->
      expect(account._addresses).to.deep.equal(addresses)

