Round = require '../../src'
Wallet = require '../../src/resources/wallet'
Wallets = require '../../src/resources/wallets'
Accounts = require '../../src/resources/accounts'
Rules = require '../../src/resources/rules'
CoinOP = require 'coinop'
PassphraseBox = CoinOP.crypto.PassphraseBox
MultiWallet = CoinOP.bit.MultiWallet

expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
credentials = require '../data/credentials'
{pubkey, privkey, newDevCreds, newUserContent, existingDevCreds, authenticateDeviceCreds} = credentials


describe 'Wallets Resource', ->
  client = developer = user = applications = ''

  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        console.log error if error
        dev.applications (error, apps) ->
          console.log error if error
          client = cli; developer = dev; applications = apps
          client.authenticateDevice authenticateDeviceCreds(apps), (error, usr) ->
            console.log error if error
            user = usr
            done(error)


  describe 'Wallet Resource', ->
    wallet = wallets = ''
    # ALERT: MOVE TO PARENT 'BEFORE' BLOCK
    before (done) ->
      wallet = data.wallet
      wallet.name = "newwallet#{Date.now()}"
      user.wallets (error, walts) ->
        wallets = walts
        wallet = walts.collection.default
        done(error)


    describe "wallet unlock", ->
      it "return a MultiWallet instance", ->
        multiwallet = wallet.unlock("passphrase")
        expect(multiwallet).to.be.an.instanceof(MultiWallet)

      it 'should memoize the multiwallet', ->
        expect(wallet._multiwallet).to.be.an.instanceof(MultiWallet)

    # skipping because it creates a wallet
    describe.skip 'wallets.create', ->
      it 'should create and return a Wallet', (done) ->
        passphrase = 'passphrase'
        name = "new-wallet#{Date.now()}"
        walletData = {name, passphrase}
        wallets.create walletData, (error, wallet) ->
          expect(wallet).to.be.an.instanceof(Wallet)
          done()

    # Skipping because it takes to long to load
    # Must clear out bez@gem.co wallets
    describe.skip 'wallets.refresh', ->
      it 'should refresh wallets.coolection with a new collection', (done) ->
        wallets.refresh (error, wallets) ->
          done(error)


    describe.only 'wallet.accounts', ->
      accounts = ''

      before (done) ->
        wallet.accounts (error, accnts) ->
          accounts = accnts
          console.log accounts
          done(error)

      it 'should return an accounts abject', ->
        expect(accounts).to.be.an.instanceof(Accounts)

      it 'should load accounts.collection with accounts', ->
        expect(accounts.collection).to.have.a.property('default')

      it 'should memoize the accounts object on the wallet', ->
        expect(wallet._accounts).to.deep.equal(accounts)


    describe.skip 'wallet.rules', ->
      it 'should return a rules object', ->
        # Note: Does not have .list
        wallet.resource().rules.list (error, rules) ->

    describe.skip 'wallet.unlock', ->
      it 'should unlock the wallet', ->


    describe 'client.wallet', ->
      it 'should return a Wallet object', ->
        walletUrl = wallet.resource().url
        client.wallet walletUrl, (error, wallet) ->
          expect(wallet).to.be.an.instanceof(Wallet)
          expect(wallet.resource().url).to.equal(walletUrl)

    
