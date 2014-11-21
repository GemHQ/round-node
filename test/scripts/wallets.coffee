Round = require '../../src'
Wallet = require '../../src/resources/wallet'
Wallets = require '../../src/resources/wallets'
Accounts = require '../../src/resources/accounts'
Rules = require '../../src/resources/rules'

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
        dev.applications (error, apps) ->
          client = cli; developer = dev; applications = apps
          client.authenticateDevice authenticateDeviceCreds(apps), (error, usr) ->
            user = usr
            done(error)


  describe 'Wallet Resource', ->
    wallet = wallets = ''
    # ALERT: MOVE TO PARENT BEFORE BLOCK
    before (done) ->
      wallet = data.wallet
      wallet.name = "newwallet#{Date.now()}"
      user.wallets (error, walts) ->
        wallets = walts
        walts.create wallet, (error, walt) ->
          wallet = walt
          done(error)

    describe 'wallets.create', ->
      it 'should create and return a Wallet', ->
        expect(wallet).to.be.an.instanceof(Wallet)

    # Skipping because it takes to long to load
    # Must clear out bez@gem.co wallets
    describe.skip 'wallets.refresh', ->
      it 'should refresh wallets.coolection with a new collection', (done) ->
        wallets.refresh (error, wallets) ->
          done(error)


    describe 'wallet.accounts', ->
      accounts = ''

      before (done) ->
        wallet.accounts (error, accnts) ->
          accounts = accnts
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


    describe 'client.wallet', ->
      it 'should return a Wallet object', ->
        walletUrl = wallet.resource().url
        client.wallet walletUrl, (error, wallet) ->
          expect(wallet).to.be.an.instanceof(Wallet)
          expect(wallet.resource().url).to.equal(walletUrl)

    
