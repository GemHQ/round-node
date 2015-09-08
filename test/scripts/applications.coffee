Round = require '../../src'
# Application = require '../../src/resources/application'
Users = require '../../src/resources/users'
Wallets = require '../../src/resources/wallets'
Application = require '../../src/resources/application'
chai = require('chai')
chai.use(require('chai-as-promised'))
expect = chai.expect
credentials = require '../data/credentials'
devCreds = credentials.developer
url = credentials.url


describe 'Applications Resource', ->
  client =  application = null
  before ->
    Round.client {url}
    .then (cli) -> 
      client = cli
      {api_token, admin_token} = devCreds
      client.authenticate_application {api_token, admin_token}
    .then (app) -> application = app
    .catch (error) -> error


  describe 'application.users', ->
    it 'should return a popluated users collection', (done) ->
      application.users().then (users) -> 
        expect(users).to.be.an.instanceof(Users)
        expect(users._list).to.have.length.above(0)
        done()


  describe 'application.wallets', ->
    it 'should hold a refrence the application it belongs to', (done) ->
      application.wallets({fetch: true}).then (wallets) ->
        wallets.getAll().forEach (wallet) ->
          console.log wallet.resource.name

        expect(wallets).to.be.an.instanceof(Wallets)
        # makes sure _list is not null - at the least it should be []
        expect(wallets._list).to.exist
        expect(wallets.application).to.be.an.instanceof(Application)
        expect(wallets.application).to.equal(application)
        done()


  describe 'application.wallet', ->
    it.only 'should return a single wallet', (done) ->
      name = 'newwallet1432670089328'
      application.wallet({name})
      .then (wallet) ->
        expect(wallet.resource.name).to.equal(name)
        done()
      .catch (error) ->
        throw new Error(error)
        done()
      
        