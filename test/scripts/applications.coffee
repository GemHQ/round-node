Round = require '../../src'
# Application = require '../../src/resources/application'
Users = require '../../src/resources/users'
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