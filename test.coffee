# works if your running from test/scripts

fs = require "fs"
yaml = require "js-yaml"
Round = require "./src"
string = fs.readFileSync "./test/data/wallet.yaml"
data = yaml.safeLoad(string)


email = () -> "js-test-#{Date.now()}@mail.com"
email2 = () -> "js-test1-#{Date.now()}@mail.com"
email3 = () -> "js-test2-#{Date.now()}@mail.com"
email4 = () -> "js-test3-#{Date.now()}@mail.com"
email5 = () -> "js-test4-#{Date.now()}@mail.com"
email6 = () -> "js-test5-#{Date.now()}@mail.com"
email7 = () -> "js-test6-#{Date.now()}@mail.com"
email8 = () -> "js-test7-#{Date.now()}@mail.com"

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

# content = { email, wallet: data.wallet }

module.exports = {
  client: (callback) -> Round.client 'http://localhost:8999', 'testnet3', callback
  pubkey: pubkey
  privkey: privkey
  email: email
  creds: {email: email(), pubkey, privkey }
  dcreds: {email: 'js-test-1415158094484@mail.com', pubkey, privkey }
}
# creds = {email: 'js-test-1415065780010@mail.com', pubkey: t.pubkey, privkey: t.privkey }


creds = {email: email(), pubkey, privkey }
# prevents conflicts when all test are being run at once
creds2 = {email: email2(), pubkey, privkey }
creds3 = {email: email3(), pubkey, privkey }
creds4 = {email: email4(), pubkey, privkey }
creds5 = {email: email5(), pubkey, privkey }
creds6 = {email: email6(), pubkey, privkey }
creds7 = {email: email7(), pubkey, privkey }
creds8 = {email: email8(), pubkey, privkey }
dcreds = {email: 'js-test-1415158094484@mail.com', pubkey, privkey }
devcreds = { developer: {email: 'js-test-1415158094484@mail.com', pubkey, privkey } }
usercontent = {email: "js-test-#{Date.now()}@mail.com", wallet: data.wallet }



# Tests if application.users works
Round.client 'http://localhost:8999','testnet3', (err, client) ->
  console.log(err, "E") if err
  
  client.developers.create creds8, (err, developer) ->
    developer.applications (err, apps) ->
      apps.default.users (err, users) ->
        users.resource().create usercontent, (err, user) ->
          console.log err, user
        # client.resources().users.create usercontent, (err, user) ->
          # console.log err, user
        # users.create usercontent, (err, user) ->
          # console.log err, user

    # client.applications.create {name: 'new app'}, (err, app) ->
    #   app.users (err, users) ->
    #     users.resource().list (err, users) -> 
    #       console.log err, users

    # Tests if users.create works
  # client.users.create usercontent, (err, user) ->
    # console.log err, user

# # Tests if client.applications.create works when
# # applications haven't been memoized
# Round.client 'http://localhost:8999','testnet3', (err, client) ->
#   console.log(err, "E") if err
  
#   client.developers.create creds7, (err, developer) ->
#     client.applications.create {name: 'new app'}, (err, app) ->
#       console.log err, app.gosh
      # developer.applications (err, apps) -> 
      #   console.log err, apps
    
# # Tests if client.applications.create works when
# # applications haven't been memoized
# Round.client 'http://localhost:8999','testnet3', (err, client) ->
#   console.log(err, "E") if err
  
#   client.developers.create creds6, (err, developer) ->
#     client.applications.create {name: 'new app'}, (err, apps) ->
#       console.log err#, apps

# # Tests if client.applications.create works when
# # applications haven't been memoized
# Round.client 'http://localhost:8999','testnet3', (err, client) ->
#   console.log(err, "E") if err
  
#   client.developers.create creds5, (err, developer) ->
#     developer.applications (error, apps) ->
#       console.log error if error
      
#       client.applications.create {name: 'new app'}, (error, apps) ->
#         console.log error#, apps

  
# Round.client 'http://localhost:8999','testnet3', (err, client) ->
#   client.patchboard().context.authorize 'Gem-Developer', dcreds
#   client.resources().developers.get (err, dev) ->
#     console.log err#, dev

# Round.client 'http://localhost:8999','testnet3', (err, client) ->
#   console.log(err, "E") if err
  
#   client.developers.create creds4, (err, developer) ->
#     developer.applications (err, apps) ->
#       console.log err#, apps
    
#     console.log(err, "F") if err

#     developer.update {email: "newemail#{Date.now()}@mail.com", privkey}, (err, developer) ->
#       console.log "!!!!! client.developer.update updates developer and returns a new developer !!!!! 7"
#       console.log err#, developer



# # Tests if client.authenticate creates authenticates a developer
# Round.client 'http://localhost:8999','testnet3', (err, client) ->

#   client.authenticate 'Gem-Developer', dcreds, (err, developer) ->
#     console.log err#, developer

# # Tests Authenticate method.
# # Returns a developer-authorized client object
# Round.authenticate devcreds, (err, client) ->
#   console.log(err, "A") if err

#   client.resources().developers.get (err, dev) ->
#     console.log "!!!!! Round.authenticate works !!!!! 1"
#     console.log err#, dev

# # Test if context.authenticate works for a developer
# Round.client 'http://localhost:8999','testnet3', (err, client) ->
#   console.log(err, "B") if err

#   client.authenticate 'Gem-Developer', dcreds, (err, developer) -> 
#     client.resources().developers.get (err, dev) ->
#       console.log "!!!!! client.patchboard.context.authorize works !!!!! 2"
#       console.log err#, dev

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


# # Tests developer.update method to see if it both updates and 
# # and reauthenticates a developer with new credentials
# Round.client 'http://localhost:8999','testnet3', (err, client) ->
#   console.log(err, "E") if err
  
#   client.developers.create creds2, (err, developer) ->
#     console.log(err, "F") if err

#     client.developer().update {email: "newemail#{Date.now()}@mail.com", privkey}, (err, developer) ->
#       console.log "!!!!! client.developer.update updates developer and returns a new developer !!!!! 7"
#       console.log err#, developer
      
#       client.resources().developers.get (err, dev) ->
#         console.log "!!!!! client.developer.update re-authorizes with new credentials !!!!! 8"
#         console.log err#, dev


# Round.client 'http://localhost:8999','testnet3', (err, client) ->
#   console.log(err, "G") if err

#   client.developers.create creds3, (err, developer) ->
#     console.log err if err

#     client.developer().update {email: "newemail1#{Date.now()}@mail.com", privkey}, (err, developer) ->
#       console.log "!!!!! client.developer.update updates developer and returns a new developer even if @_developer wasn't memoized !!!!! 9"
#       console.log err#, developer

