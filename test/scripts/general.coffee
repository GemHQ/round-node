Round = require '../../src'
Developer = require '../../src/resources/developer'
Developers = require '../../src/resources/developers'
Applications = require '../../src/resources/applications'
Users = require '../../src/resources/users'
expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)
keys = require '../data/keys'
pubkey =  keys.pubkey
privkey = keys.privkey

email = () -> "js-test-#{Date.now()}@mail.com"
existingDevCreds = {email: 'js-test-1415675506694@mail.com', pubkey, privkey }
existingDevApiToken = 'HTqU6tkpygsTWITOEyfwsEMFXX8PjgKDt7kL1gZVW4g'
newDevCreds = -> {email: email(), pubkey, privkey }
newUserContent = -> {email: "js-test-#{Date.now()}@mail.com", wallet: data.wallet }
newBezContent = {email: "bez@gem.co", wallet: data.wallet }


describe 'Round.client', ->
  it 'should create a new client with a property of patchboard', (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, client) ->
      client.developers.create newDevCreds(), (error, developer) ->
        done(error)

describe 'Client Methods', ->
  
  describe 'Round.client', ->
    it 'should create a new client with a property of patchboard', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        expect(client).to.have.property 'patchboard'
        expect(client.patchboard()).to.have.property 'resources'
        done(error)

  describe 'client.authenticateDeveloper', ->
    it 'should authenticate a client as a Gem-Developer & memoize _developer on the client ', (done) ->  
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        client.authenticateDeveloper existingDevCreds, (error, developer) ->
          expect(client).to.have.property('_developer')
          done(error)

  describe.skip 'client.authenticateDevice()', ->
    it 'should autheticate client as a device and return a user', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        client.authenticateDeveloper existingDevCreds, (error, developer) ->
          developer.applications (error, apps) ->
            apiToken = apps.default.api_token
            
            client.users.create newUserContent(), (error, user) ->
              console.log user.user_token
              deviceCreds = {
                api_token: apiToken,
                user_url: user.url,
                user_token: user.user_token,
                device_id: "awesomeid#{Date.now()}"
              }
              
              client.authenticateDevice deviceCreds, (error, user) ->
                # console.log error, user
                # console.log client.patchboard().context.schemes['Gem-Device']
                expect(client.patchboard().context.schemes['Gem-Device']).to.have.a.property('credentials')
                done(error)


  describe 'client.developer()', ->
    it 'should throw an error if a developer has NOT been authenticated', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        expect(client.developer).to.throw('You have not yet authenticated as a developer')
        done(error)

    it 'should return a devloper object if previously authorized', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        client.authenticateDeveloper existingDevCreds, (error, developer) ->
          expect(developer).to.be.an.instanceof(Developer)
          done(error)

  describe 'client.developers', ->
    it 'should return an instance of developers', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        expect(client.developers).to.be.an.instanceof(Developers)
        done(error)

  describe 'client.applications', ->
    it 'should return an instance of Applications', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        expect(client.applications).to.be.an.instanceof(Applications)
        done(error)

  describe 'client.users', ->
    it 'should return an instance of users', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        expect(client.users).to.be.an.instanceof(Users)
        done(error)

  describe.skip 'client.user(callback)', ->
    it 'should throw an error if not already authorized as a device', ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        client.user (error, user) ->
          done(error)

    # Build this out once authenticate device works
    it 'should return a user', ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        client.authenticateDeveloper existingDevCreds (error, developer) -> 



describe 'Developer Resource', ->
  client = developer = ''
  
  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.developers.create newDevCreds(), (error, dev) ->
        client = cli; developer = dev; done(error)

  describe 'client.developers.create', ->
    it 'should return a developer object (and authorize if privkey is provided)', (done) ->
      expect(developer).to.be.an.instanceof(Developer)
      # proves that client is authorized as a developer
      client.resources().developers.get (error, developer) ->
        done(error)

  describe 'developer.applications(callback)', ->
    it 'should return an instance of Applications', (done) ->
      developer.applications (error, applications) ->
        expect(applications).to.be.an.instanceof Applications
        done(error)

  describe 'developer.update {email: ...}', ->
    it 'should persist updated data, reauthorize with new credentials, memoize and return updated developer', (done) ->
      newEmail = "thenewemail#{Date.now()}@mail.com"
      developer.update {email: newEmail, privkey}, (error, updatedDeveloper) ->
        expect(updatedDeveloper).to.be.an.instanceof(Developer)
        expect(updatedDeveloper.resource().email).to.equal(newEmail)
        expect(client.developer()).to.deep.equal(updatedDeveloper)
        # proves that updatedDeveloper has been authorized
        client.resources().developers.get (error, developer) ->
          done(error)



describe.only 'User Resource', ->
  client = developer = user = applications =''

  before (done) ->
    Round.client 'http://localhost:8999','testnet3', (error, cli) ->
      cli.authenticateDeveloper existingDevCreds, (error, dev) ->
        cli.users.create newUserContent(), (error, usr) ->
          dev.applications (error, apps) ->
            client = cli; developer = dev; user = usr; applications = apps; done(error)

  describe 'client.users.create', ->
    it 'should create a user object', (done) ->
      expect(user.resource()).to.have.a.property('email') 
      done()

  describe 'user.beginDeviceAuthorization', ->
    it 'should do stuff I dont know yet', (done) ->
      client.patchboard().context.schemes['Gem-OOB-OTP']['credentials'] = 'data="none"'

      # # FIRST
      # u = client.resources().user_query {email: 'bez@gem.co'}
      # device_id =  "newdeviceid#{Date.now()}"
      # console.log 'device_id ------------------------------'
      # console.log device_id
      # u.authorize_device {name: 'newapp', device_id}, (error, data) ->
      #   regx = /"(.*)"/
      #   response = error.response.headers['www-authenticate']
      #   matches = regx.exec response
      #   key = matches[1]
      #   console.log key
      #   done()

      # # SECOND
      # api_token = applications.default.api_token
      # app_url = applications.default.url
      # key = 'otp.rQQNCg3KqGaEP9FiiPMPKw'
      # secret = '_2JGgbc__BX6OogedvvWLw'
      # device_id = 'newdeviceid1415848739326'
      # user_token = 'iTm14NBmJkvUnLkR0v-GktkDH1gFqOwMfdyHFTwzPjE'
      # name = 'newapp'
      # client.authenticateOTP {api_token, key, secret}
      # u = client.resources().user_query {email: 'bez@gem.co'}
      # u.authorize_device {name, device_id}, (error, data) ->
      #   console.log error, data
      #   console.log "AUTHENTICATING THE DEVICE ----------------------"
      #   client.authenticateDevice {app_url, api_token, user_url: data.url, user_token, device_id}, (error, user) ->
      #     console.log error,user
      #     done(error)
