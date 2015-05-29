Round = require('../../src')
Account = require('../../src/resources/account')
Wallet = require('../../src/resources/wallet')
Addresses = require('../../src/resources/addresses')
Transactions = require('../../src/resources/transactions')
expect = require('chai').expect
credentials = require('../data/credentials')
devCreds = credentials.developer
url = credentials.url


describe 'Accounts Resource', ->
  wallet = accounts = null
  before (done) ->
    Round.client {url}, (error, cli) ->
      {api_token, admin_token, totp_secret} = devCreds
      cli.authenticate_application {api_token, admin_token, totp_secret}, (error, app) ->
        app.wallets (error, wallts) ->
          wallet = wallts.get(0)
          wallet.accounts (error, accnts) ->
            accounts = accnts
            done(error)


  describe 'Account', ->
    account = null
    before ->
      account = accounts.get(0)

    describe 'account.addresses', ->
      it 'should return a new Addresses object', (done) ->
        account.addresses (error, addresses) ->
          expect(addresses).to.be.an.instanceof(Addresses)
          done(error)

    describe 'account.transactions', ->
      it 'should return a new transactions object', (done) ->
        account.transactions (error, transactions) ->
          expect(transactions).to.be.an.instanceof(Transactions)
          done(error)




  describe 'Accounts', ->

    describe.skip 'accounts.create', ->
      account = null
      before (done) ->
        name = "newAccount#{Date.now()}"
        network = 'bitcoin_testnet'
        accounts.create {name, network}, (error, accnt) ->
          account = accnt
          done(error)

      it 'should create a new account object', ->
        expect(account).to.be.an.instanceof(Account)

      it 'should have a refrence to the wallet it belongs to', ->
        expect(account.wallet).to.be.an.instanceof(Wallet)
        expect(account.wallet).to.equal(wallet)


    describe.only 'account.pay', ->
      it 'should create a successful transaction', (done) ->
        wallet = wallet.unlock {passphrase: 'password'}
        payees = [{
          # bitcoin/coinbase address
          address: '18XcgfcK4F8d2VhwqFbCbgqrT44r2yHczr',
          # dogecoin/cryptonator address
          # address: 'DB8QuLZComTJ9oa7maXQYUuxUNLkC5ksJm'
          amount: 50000
        }]
        # account = accounts.get('dogecoin')
        account = accounts.get('bitcoin')
        account.transactions {status: 'unsigned,signed,unapproved'}, (err, txs) ->
          
          account.pay {payees, confirmations: 1}, (error, data) ->
            console.log error, data
            expect(data).to.exist
            done(error)