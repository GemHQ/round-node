Round = require('../../src')
Account = require('../../src/resources/account')
Wallet = require('../../src/resources/wallet')
Addresses = require('../../src/resources/addresses')
Transactions = require('../../src/resources/transactions')
expect = require('chai').expect
credentials = require('../data/credentials')
devCreds = credentials.developer
url = credentials.url
Promise = require('bluebird')


describe 'Accounts Resource', ->
  client = wallet = accounts = null
  before (done) ->
    Round.client({url})
    .then (client) -> 
      {api_token, admin_token, totp_secret} = devCreds
      client.authenticate_application {api_token, admin_token, totp_secret}
    .then (app) -> app.wallets()
    .then (wallts) ->
      wallet = wallts.get(0)
      wallet.accounts()
    .then (accnts) -> 
      accounts = accnts
      done()
    .catch (error) -> done(error)


  # describe 'Account', ->
  #   account = null
  #   before ->
  #     account = accounts.get(0)

  #   describe 'account.addresses', ->
  #     it 'should return a new Addresses object', (done) ->
  #       account.addresses()
  #       .then (addresses) ->
  #         expect(addresses).to.be.an.instanceof(Addresses)
  #         done()
  #       .catch (error) -> done(error)

  #   describe 'account.transactions', ->
  #     it 'should return a new transactions object', (done) ->
  #       account.transactions()
  #       .then (transactions) -> 
  #         expect(transactions).to.be.an.instanceof(Transactions)
  #         done()
  #       .catch (error) -> done(error)




  describe 'Accounts', ->

    describe.skip 'accounts.create', ->
      account = null
      before (done) ->
        name = "newAccount#{Date.now()}"
        network = 'bitcoin_testnet'
        accounts.create {name, network}
        .then (accnt) -> account = accnt; done()
        .catch (error) -> done(error)

      it 'should create a new account object', ->
        expect(account).to.be.an.instanceof(Account)

      it 'should have a refrence to the wallet it belongs to', ->
        expect(account.wallet).to.be.an.instanceof(Wallet)
        expect(account.wallet).to.equal(wallet)


    describe.only 'account.pay', ->
      it.skip 'should create a successful bitcoin tx', (done) ->
        wallet = wallet.unlock {passphrase: 'password'}
        payees = [{
          address: '18XcgfcK4F8d2VhwqFbCbgqrT44r2yHczr',
          amount: 50000
        }]
        account = accounts.get('bitcoin')
        account.pay({payees, confirmations: 1})
        .then (data) ->
          console.log(data)
          expect(data).to.exist
          done()
        .catch (error) -> done(error)


    describe 'account.pay dogecoin', ->
      it 'should create a successful transaction dogecoin tx', (done) ->
        wallet = wallet.unlock {passphrase: 'password'}
        payees = [{
          address: 'DB8QuLZComTJ9oa7maXQYUuxUNLkC5ksJm'
          amount: 500000000
        }]
        account = accounts.get('dogecoin')
        account.pay({payees, confirmations: 1})
        .then (data) ->
          console.log(data)
          expect(data).to.exist
          done()
        .catch (error) -> done(error)
