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
  before ->
    Round.client {url}
    .then (cli) -> 
      client = cli
      {api_token, admin_token} = devCreds
      client.authenticate_application {api_token, admin_token}
    .then (app) -> 
      application = app
      application.wallets()
    .then (wallts) -> wallets = wallts
    .catch (error) -> error


  describe 'Wallets', ->

    describe 'wallets.create', ->
      wallet = null
      before (done) ->
        name = "newwallet#{Date.now()}"
        passphrase = 'password'
        wallets.create({name, passphrase})
        .then (data) -> 
          {wallet, backup_key} = data
          done()


      it 'should create a new Wallet object', ->
        expect(wallet).to.be.an.instanceof(Wallet)
        
      it 'the created wallet should hold a refrence to the application', ->
        expect(wallet.application).to.be.an.instanceof(Application)

      it 'the created wallet should have a multiwallet property', ->
        expect(wallet).to.have.a.property('multiwallet')



  describe 'Wallet', ->

    describe 'wallet.accounts', ->
      it 'accounts should hold a reference to the wallet', (done) ->
        wallet = wallets.get(0)
        wallet.accounts()
        .then (accounts) -> 
          expect(accounts).to.be.an.instanceof(Accounts)
          expect(accounts.wallet).to.exist
          expect(accounts.wallet).to.equal(wallet)
          done()
        .catch (error) -> done(error)


    describe 'wallet.unlock', ->
      it 'should retrun a wallet that has a multiwallet property', ->
        wallet = wallets.get(0).unlock({passphrase: 'password'})
        expect(wallet.multiwallet).to.exist
