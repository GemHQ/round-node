Round = require('../../src')
Wallets = require('../../src/resources/wallets')
Wallet = require('../../src/resources/wallet')
Application = require('../../src/resources/application')
Accounts = require('../../src/resources/accounts')
# Devices = require('../../src/resources/devices')
expect = require('chai').expect
credentials = require('../data/credentials')
devCreds = credentials.developer
url = credentials.url


describe 'Wallets Resource', ->
  client =  application = wallets = null
  before (done) ->
    Round.client {url}, (error, cli) ->
      {api_token, admin_token} = devCreds
      cli.authenticate_application {api_token, admin_token}, (error, app) ->
        app.wallets (error, wallts) ->
          client = cli; application = app; wallets = wallts
          done(error)


  # describe 'Wallets', ->

  #   describe 'wallets.create', ->
  #     wallet = null
  #     before (done) ->
  #       name = "newwallet#{Date.now()}"
  #       passphrase = 'password'
  #       wallets.create {name, passphrase}, (error, wallt) ->
  #         wallet = wallt
  #         done(error)


  #     it 'should create a new Wallet object', ->
  #       expect(wallet).to.be.an.instanceof(Wallet)
        
  #     it 'the created wallet should hold a refrence to the application', ->
  #       expect(wallet.application).to.be.an.instanceof(Application)

  #     it 'the created wallet should have a multiwallet property', ->
  #       expect(wallet).to.have.a.property('multiwallet')




  describe 'Wallet', ->

    describe 'wallet.accounts', ->
      it 'accounts should hold a reference to the wallet', (done) ->
        wallet = wallets.get(0)
        wallet.accounts (error, accounts) ->
          expect(accounts).to.be.an.instanceof(Accounts)
          expect(accounts.wallet).to.exist
          expect(accounts.wallet).to.equal(wallet)
          done(error)


    describe 'wallet.unlock', ->
      it 'should retrun a wallet that has a multiwallet property', ->
        wallet = wallets.get(0).unlock({passphrase: 'password'})
        expect(wallet.multiwallet).to.exist
