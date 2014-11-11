Round = require '../../src'
expect = require('chai').expect
fs = require "fs"
yaml = require "js-yaml"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)

pubkey =  """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwJyfSUKm9Xd48yfImxDX
DoBqh7O6PacgDfmXBEztFFA3A4ReoEGxtNj+9PWnrWwgcWeGEL62d9UWdTbVtUrh
skXrWMtnt+HUzwEwdN0At3V0e3XdGwtndl9TJ94L7smltmSDHIxRl25Dj7sgmwmo
Ht59UDik/Y8a/8/Fr500VF6mNV8+1fsy3rLp/is840Uomd++V3iuFCjzVIsJPo1y
JlY/qSrPr4z2y/sH8GbiiuI3vDM+OW3RFDReBx6c0m/3x7UaBW7++lWveuIWB4aT
HY+dXai8khSDDFobckR6EjfrCvIJlFAdi+frMZx7g31gxMaCXMbERDjQUS8vWvdG
rQIDAQAB
-----END PUBLIC KEY-----
"""

privkey = """-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAwJyfSUKm9Xd48yfImxDXDoBqh7O6PacgDfmXBEztFFA3A4Re
oEGxtNj+9PWnrWwgcWeGEL62d9UWdTbVtUrhskXrWMtnt+HUzwEwdN0At3V0e3Xd
Gwtndl9TJ94L7smltmSDHIxRl25Dj7sgmwmoHt59UDik/Y8a/8/Fr500VF6mNV8+
1fsy3rLp/is840Uomd++V3iuFCjzVIsJPo1yJlY/qSrPr4z2y/sH8GbiiuI3vDM+
OW3RFDReBx6c0m/3x7UaBW7++lWveuIWB4aTHY+dXai8khSDDFobckR6EjfrCvIJ
lFAdi+frMZx7g31gxMaCXMbERDjQUS8vWvdGrQIDAQABAoIBAQCGgVliyZ7aMBJQ
i2m1j+7+e4LpPQND5p+l4rQpFqdA1jt0w01pUDcO+bIh0iLEIowNZaPjsaquyCmk
tSRMM/ykh9sv6OuHJ7d6z3PNSEAl3Wn4hXhgWHhp22uwnYlruXl1g39jwkGAJEod
5yl/2yCCXhDYopXlU7ghCDEe0AMpHrGBtlVoAOgNyocv5BIIsMR3W9o7JyZO9WWh
XgZhb5NP6oLRxx+iW5qz3iN+8l1AHfEkCGKt1LxUh2yv5iO1u2N747iwPQ53zMSj
+rxZVYI4wnsIkvwEFz7d9vvO1fw2GRlL/oU3idbOr9nHw46xNNt+s7ihrnXDHXRg
jXOJDLIBAoGBAN+loj22wzMgezNMj0CN/KN8KBfGXzfDtKl2PCYbavDT8iesbHU+
uMIXlV4vzFIob2mIh7PXKMiU8l/8rEk4BvOj9L1qVTn7AMugxXo0SnBB7/QLeW45
ddeRGN6z3sUv+EIGSu9Eq+JYCoc8CyMX7gR54flLXL0DqRyB9c/4ZspBAoGBANx5
p8aWfxggpt2Z3NyLrs+C3x80myBiOK3YbPAYX3A92h22rXPWwtZR6+GX8ETmnsl9
+qRtQke7adt0DO06frZ7LHvz+W8kEzqjpOFA3yZB4h2KWzlonFOKy33jfuUFv/5f
Gnt2L+z6TV+H/c3cUdwZZ3+KLOo8DqXkcoz1nultAoGADOVdJJfcS59s2zln7T4C
ul6XZT+QEAQd78OclknwcbCW/winPF+AgdigSU0SSA6C1iAESy9175L/It/MA3DS
ncvvediez3gUxKkhmflX7X8v2e+rcdqoW+TG/Vh72Pz6ILyCJ6fbDXMsMD4bGkvv
8pwglqJs141VfApWZUaajsECgYAPpz+HNPYvE1plj2AD9JLjvsnyoDyHTxHxHdWW
MlTMVkffJjIocE4DA2v4512ytqD9c0lRVUSIbUD1yMaGLUoD0Lj2z/qcrnYDCs1R
BNcTE0hnioQxjkDTGZ6bAITo48Ce4ceyjlCWxaqqprAZZpQVSWR0xK2tr7fmhVKw
uVuf/QKBgHAp200rLep+QptWoPaWetvwiQkRoIZrHrTS2McBb2LVyCxp0+oGWOk5
cY8ZVD2l4RqnCto6mgAsXxkVlbbM3u0vg2Cvfz97WuI/cYPofGD8K2IY4E4k1zWd
nDx0pX2tKDrix8yGKr/EttgjRKyymTIngxSZb9vLTX9aEOubIxCp
-----END RSA PRIVATE KEY-----
"""
email = () -> "js-test-#{Date.now()}@mail.com"
existingDevCreds = {email: 'js-test-1415675506694@mail.com', pubkey, privkey }
existingDevApiToken = 'HTqU6tkpygsTWITOEyfwsEMFXX8PjgKDt7kL1gZVW4g'
newDevCreds = -> {email: email(), pubkey, privkey }
newUserContent = -> {email: "js-test-#{Date.now()}@mail.com", wallet: data.wallet }


# describe 'Client Methods', ->
#   describe 'Round.client', ->
#     it 'should create a new client with a property of patchboard', (done) ->
      
#       Round.client 'http://localhost:8999','testnet3', (error, client) ->
#         client.developers.create newDevCreds(), (error, developer) ->
#           console.log error, developer.resource()
#           done()


describe 'Client Methods', ->
  describe 'Round.client', ->
    it 'should create a new client with a property of patchboard', (done) ->
      
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        expect(client).to.have.property 'patchboard'
        expect(client.patchboard()).to.have.property 'resources'
        done()

  describe "Round.authenticate 'Gem-Developer' ", ->
    it 'should authenticate a client as a Gem-Developer & memoize _developer on the client ', (done) ->

      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        client.authenticate 'Gem-Developer', existingDevCreds, (error, developer) ->
          expect(client).to.have.property('_developer')
          
          client.resources().developers.get (error, developer) ->
            expect(developer).to.have.property('email', 'js-test-1415675506694@mail.com' )
            done()


describe 'User Resource', ->
  describe 'client.users.create', ->
    it 'should create a user object', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        client.authenticate 'Gem-Developer', existingDevCreds, (error, developer) ->
          client.users.create newUserContent(), (error, user) ->
            expect(user).to.have.a.property('email')
            done()

describe 'Device Auth', ->
  describe 'client.authenticateDevice', (done) ->
    it 'should authenticate the client as a device', (done) ->
      Round.client 'http://localhost:8999','testnet3', (error, client) ->
        client.authenticate 'Gem-Developer', existingDevCreds, (error, developer) ->
          developer.applications (error, apps) ->
            apiToken = apps.default.api_token
            
            client.users.create newUserContent(), (error, user) ->
              deviceCreds = {
                api_token: apiToken,
                user_url: user.url,
                user_token: user.user_token,
                device_id: "awesomeid#{Date.now()}"
              }
              client.authenticateDevice deviceCreds, (error, user) ->
                console.log error, user
                # console.log client.patchboard().context.schemes['Gem-Device']
                expect(client.patchboard().context.schemes['Gem-Device']).to.have.a.property('credentials')
                done(error)




#     client.developer().applications (err, apps) ->
#       console.log "!!!!! client.developer().applications works for after client.autheticate !!!!! 3"
#       console.log err#, apps

# # Tests if developer has been created AND authorized
# # using the 'create' convenience method
# Round.client 'http://localhost:8999','testnet3', (err, client) ->
#   console.log(err, "C") if err

#   client.developers.create creds, (err, developer) ->
#     console.log(err, "D") if err
    
#     developer.applications (err, apps) ->
#       console.log "!!!!! client.developer.create works !!!!! 4"
#       console.log err#, apps
      
#     # tests that the developer can be accessed from the client
#     client.patchboard().resources.developers.get (err, dev) ->
#       console.log "!!!!! resources.developers.get works after dev has been created !!!!! 5"
#       console.log err#, dev 

#     client.developer().applications (err, apps) ->
#       console.log "!!!!! client.applications works when @_developer exists on the client !!!!! 6"
#       console.log err#, apps
#       # console.log client._applications


# describe 'TestAsync', ->
#   it 'should return true', (done)->
#     hi = (callback) ->
#       setTimeout (->
#               x = 2
#               callback(x)), 1000
#     hi (x) ->
#       expect(x).to.equal(2)
#       done()
    
