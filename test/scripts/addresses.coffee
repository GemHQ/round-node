Round = require('../../src')
Address = require('../../src/resources/address')
# Devices = require('../../src/resources/devices')
expect = require('chai').expect
credentials = require('../data/credentials')
devCreds = credentials.developer
url = credentials.url


describe 'Addresses Resource', ->
  addresses = null
  before (done) ->
    Round.client {url}, (error, cli) ->
      {api_token, admin_token} = devCreds
      cli.authenticate_application {api_token, admin_token}, (error, app) ->
        app.wallets (error, wallets) ->
          wallet = wallets.get(0)
          wallet.accounts (error, accounts) ->
            account = accounts.get(1)
            console.log account
            account.addresses (error, addrs) ->
              addresses = addrs
              done(error)


  describe 'Address', ->
    describe 'addresses.create', ->
      address = null

      before (done) ->
        addresses.create (error, addr) ->
          address = addr
          done(error)

      it 'should create an addresses object', ->
        console.log address
        expect(address).to.be.an.instanceof(Address)
