Round = require('../../src')
expect = require('chai').expect
credentials = require('../data/credentials')
devCreds = credentials.developer
url = credentials.url


describe 'Collection fetch === true', ->
  client =  application = wallets = null
  before ->
    Round.client {url}
    .then (cli) -> 
      client = cli
      {api_token, admin_token} = devCreds
      client.authenticate_application {api_token, admin_token}
    .then (app) -> 
      application = app
      application.wallets({fetch: true})
    .then (wllts) ->
      wallets = wllts
    .catch (error) -> error


  it 'should return a collection', ->
    expect(wallets.getAll()).to.be.an.instanceof(Array)

  it 'should not return the memoized collection', ->
    application.wallets({fetch: true})
    .then (newWallets) ->
      expect(newWallets).to.not.equal(wallets)
      

describe 'Collection fetch === false', ->
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
    .then (wllts) ->
      wallets = wllts
    .catch (error) -> error


  it 'should return not fetch the collection', ->
    expect(wallets.getAll()).to.have.length(0)