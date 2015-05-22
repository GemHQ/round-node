Round = require '../../src'
Wallets = require '../../src/resources/wallets'
Users = require '../../src/resources/users'
expect = require('chai').expect
credentials = require '../data/credentials'
devCreds = credentials.developer
url = credentials.url



describe 'Applications Resource', ->
  client =  application = users = null
  before (done) ->
    Round.client {url}, (error, cli) ->
      {api_token, admin_token} = devCreds
      cli.authenticate_application {api_token, admin_token}, (error, app) ->
        app.users (error, usrs) ->
          client = cli; application = app; users = usrs
          done(error)


  describe 'Base.getAssociatedCollection', ->
    it 'should return a popluated users collection', ->
      # application inherits from Base, and calls getAssociatedCollection
      # on application.users
      expect(users).to.be.an.instanceof(Users)
      expect(Array.isArray(users._list)).to.be.true


    it 'should return the memoized collection - aka not make a network request', ->
      # since we don't have to use done, it means the call was synchronous
      application.users (error, usrs) ->
        expect(users).to.be.an.instanceof(Users)


    it 'should return a popluated wallets collection', (done) ->
      # application inherits from Base, and calls getAssociatedCollection
      # on application.users
      user = users.get(0)
      user.wallets (error, wallets) ->
        expect(wallets).to.be.an.instanceof(Wallets)
        expect(Array.isArray(wallets._list)).to.be.true
        done(error)


  describe.only "Base.update", ->
    it 'should update the in memory properties', (done) ->
      # user.update inherits from Base.update
      user = users.get(0)
      console.log user.resource.devices.create
      # user.update {first_name: 'bez'}, (error, user) ->
      #   console.log error, user
      done(error)