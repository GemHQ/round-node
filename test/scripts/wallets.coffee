Round = require('../../src')
Devices = require('../../src/resources/devices')
expect = require('chai').expect
credentials = require('../data/credentials')
devCreds = credentials.developer
userCreds = credentials.user
url = credentials.url


describe 'Wallets Resource', ->
  client =  application = users = user = null
  before (done) ->
    Round.client {url}, (error, cli) ->
      {api_token, admin_token} = devCreds
      cli.authenticate_application {api_token, admin_token}, (error, app) ->
        app.users (error, usrs) ->
          client = cli; application = app; users = usrs
          user = usrs.get(userCreds.email)
          done(error)



  describe 'Wallets', ->
    wallets = null
    before (done) ->
      user.wallets (error, wallts) ->
        wallets = wallts
        done(error)

    describe 'wallets.create', ->
      it 'should create a new wallet', ->
        


  # describe 'Wallet', ->
  #   wallets = null
  #   before (done) ->
  #     user.wallets (error, wallts) ->
  #       wallets = wallts
  #       done(error)


  #   describe ''

  # describe 'Wallet Resource', ->
  #   describe "wallet unlock", ->
  #     it "return a MultiWallet instance", ->
  #       multiwallet = wallet.unlock("passphrase")
  #       expect(multiwallet).to.be.an.instanceof(MultiWallet)

  #     it 'should memoize the multiwallet', ->
  #       expect(wallet._multiwallet).to.be.an.instanceof(MultiWallet)

  #   # skipping because it creates a wallet
  #   describe.skip 'wallets.create', ->
  #     it 'should create and return a Wallet and a backup_seed', (done) ->
  #       passphrase = 'passphrase'
  #       name = "new-wallet#{Date.now()}"
  #       walletData = {name, passphrase}
  #       wallets.create walletData, (error, backup_seed, walet) ->
  #         expect(wallet).to.be.an.instanceof(Wallet)
  #         expect(backup_seed).to.exist
  #         done()


  #   # Find a good way to test without overwriting the default wallet
  #   # describe.skip "wallet.update", ->
  #   #   it 'should update the wallets resource with a new name', (done) ->


  #   # Skipping because it takes to long to load
  #   # Must clear out bez@gem.co wallets
  #   describe.skip 'wallets.refresh', ->
  #     it 'should refresh wallets.coolection with a new collection', (done) ->
  #       wallets.refresh (error, wallets) ->
  #         done(error)


  #   describe.only 'wallet.accounts', ->
  #     accounts = ''

  #     before (done) ->
  #       wallet.accounts (error, accnts) ->
  #         accounts = accnts
  #         console.log accounts
  #         done(error)

  #     it 'should return an accounts abject', ->
  #       expect(accounts).to.be.an.instanceof(Accounts)

  #     it 'should load accounts.collection with accounts', ->
  #       expect(accounts.get('default')).to.exist

  #     it 'should memoize the accounts object on the wallet', ->
  #       expect(wallet._accounts).to.deep.equal(accounts)


  #   describe.skip 'wallet.rules', ->
  #     it 'should return a rules object', ->
  #       # Note: Does not have .list
  #       wallet.resource().rules.list (error, rules) ->

  #   describe.skip 'wallet.unlock', ->
  #     it 'should unlock the wallet', ->


  #   describe 'client.wallet', ->
  #     it 'should return a Wallet object', ->
  #       walletUrl = wallet.resource().url
  #       client.wallet walletUrl, (error, wallet) ->
  #         expect(wallet).to.be.an.instanceof(Wallet)
  #         expect(wallet.resource().url).to.equal(walletUrl)

    
