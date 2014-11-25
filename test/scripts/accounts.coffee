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
  client = developer = user = applications = accounts = wallet = ''

  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        console.log error, dev
        dev.applications (error, apps) ->
          client = cli; developer = dev; applications = apps;

          client.authenticateDevice authenticateDeviceCreds(applications), (error, usr) ->
            user = usr
            wallet = data.wallet
            wallet.name = "newwallet#{Date.now()}"
            user.wallets (error, wallets) ->
              wallets.create wallet, (error, walletObj) ->
                wallet = walletObj
                wallet.accounts (error, accnts) ->
                  accounts = accnts
                # accountUrl = wallet.resource().accounts.url
                # account = client.account accountUrl
                  done(error)

  # Note: We may be removing client.account
  describe 'client.account', ->
    it 'should return an Account object', ->
      accountUrl = wallet.resource().accounts.url
      account = client.account accountUrl
      expect(account).to.be.an.instanceof(Account)



  describe 'Account Creation', ->
    account = ''

    before (done) ->
      name = "newAccount"
      accounts.create {name}, (error, accnt) ->
        account = accnt
        done(error)
  
    describe 'accounts.create', ->
      it 'should create a new Account object', () ->
        expect(account).to.be.an.instanceof(Account)

      it 'should memoize the new account', () ->
        wallet.accounts (error, accounts) ->
          expect(wallet._accounts.collection).to.have.a.property('newAccount')

    # currently receiving a 401, not sure why
    describe.skip 'account.update', ->
      it 'should update the account resource', (done) ->
        
        account.resource().update {name}, (error, accountResource) ->
          console.log error, accountResource
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

    # account.resource().transactions returns a funcrion
    # not a resource. Could be a bug in Patchboard
    describe.skip 'account.transactions', ->
      it 'should return a transactions object', (done) ->
        console.log account.resource().transactions
        done()

    describe.skip 'account.payments', ->
      it 'should return a payments object', (done) ->
        account.resource().payments.list (error, payment) ->
          console.log error, payments
          done()

    describe.skip 'account.pay', ->
      it 'should make payment to the payees', ->

    # describe.only 'addresses.create', ->
    #   it 'should create an addresses object', (done) ->
    #     account.resource().addresses.create (error, adddressResource) ->
    #       console.log adddressResource
    #       done()
        # account.addresses (error, addresses) ->
        #   addresses.create (error, address)  ->
        #     console.log error, address.resource()
        #     done()




