Round = require '../../src'
# Application = require '../../src/resources/application'
Users = require '../../src/resources/users'
Wallets = require '../../src/resources/wallets'
Application = require '../../src/resources/application'
expect = require('chai').expect
credentials = require '../data/credentials'
devCreds = credentials.developer
url = credentials.url



describe 'Applications Resource', ->
  client =  application = null
  before (done) ->
    Round.client {url}, (error, cli) ->
      {api_token, admin_token} = devCreds
      cli.authenticate_application {api_token, admin_token}, (error, app) ->
        client = cli; application = app
        done(error)


  describe 'application.users', ->
    it 'should return a popluated users collection', (done) ->
      application.users (error, users) ->
        expect(users).to.be.an.instanceof(Users)
        expect(users._list).to.have.length.above(0)
        done(error)


  describe 'application.wallets', ->
    it 'should hold a refrence the application it belongs to', (done) ->
      application.wallets (error, wallets) ->
        expect(wallets).to.be.an.instanceof(Wallets)
        # makes sure _list is not null - at the least it should be []
        expect(wallets._list).to.exist
        expect(wallets.application).to.be.an.instanceof(Application)
        expect(wallets.application).to.equal(application)
        done(error)