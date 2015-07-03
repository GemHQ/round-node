
Round = require '../../src'
creds = require('../data/credentials')
developersCreds = creds.developer
userCreds = creds.user
url = creds.url
Application = require('../../src/resources/application')
chai = require('chai')
chai.use(require('chai-as-promised'))
expect = chai.expect



describe 'Client Methods', ->

  # client = null
  # before (done) ->
  #   Round.client {url}
  #   .then (cli) -> client = cli; done()
  #   .catch (error) -> throw error

  # describe 'Round.client', ->
  #   it 'should create a new client with a property of patchboard', ->
  #     expect(client).to.have.property 'patchboard'
  #     expect(client.patchboard).to.have.property 'resources'
  #     expect(client.patchboard).to.have.property 'context'


  # describe "client.authenticate_application", ->
  #   it 'should return an Application object', ->
  #     application = client.authenticate_application(developersCreds)
  #     expect(application).to.eventually.be.an.instanceof(Application)


  # describe 'client.authenticate_identify', ->
  #   it 'should allow a user to be feetched', (done) ->
  #     {api_token} = developersCreds
  #     client.authenticate_identify({api_token})
  #     {email} = userCreds
  #     client.user({email})
  #     .then (user) ->
  #       expect(user).to.exist
  #       done()
  #     .catch (error) -> done(error)


  # describe.only 'user creation', ->
  #   it 'should create a user on the production stack', (done) ->
  #     Round.client()
  #     .then (cli) ->
  #       api_token = '2w7U-HI9UGA2HdG0FFuLhAPD5QO3zUiR1gvvw-CTB0w'
  #       cli.authenticate_identify({api_token})
  #       cli.users.create({
  #         first_name: 'bez',
  #         last_name: 'reyhan',
  #         email: "bez+#{Date.now()}@gem.co",
  #         device_name: 'devy',
  #         passphrase: 'password'
  #       })
  #     .then (device_token) -> 
  #       console.log device_token
  #       console.log {
  #         first_name: 'bez',
  #         last_name: 'reyhan',
  #         email: "bez+#{Date.now()}@gem.co",
  #         device_name: 'devy',
  #         passphrase: 'password'
  #       }
  #       expect(device_token).to.exist
  #       done()
  #     .catch (error) -> throw new Error(error)


  describe.only 'user search', ->
    it 'get a user from the production stack', (done) ->
      Round.client()
      .then (cli) ->
        api_token = '2w7U-HI9UGA2HdG0FFuLhAPD5QO3zUiR1gvvw-CTB0w'
        cli.authenticate_identify({api_token})
        cli.user({email: 'bez+1435862688247@gem.co'})
      .then (user) -> user.devices()
      .then (devices) -> devices.create({name: "newDevice#{Date.now()}"})
      .then (data) -> console.log data
      # .then ({device_token, mfa_uri}) -> console.log device_token, mfa_uri
      .catch (error) -> console.log(error); done(error)



# PScUS_nfiyaCn-1uE0H3-kgwEuXsstuK10DF0j1ay74
# { first_name: 'bez',
#   last_name: 'reyhan',
#   email: 'bez+1435862701756@gem.co',
#   device_name: 'devy',
#   passphrase: 'password' }