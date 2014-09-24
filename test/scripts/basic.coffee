fs = require "fs"

yaml = require "js-yaml"

Round = require "../../src"

string = fs.readFileSync "test/data/wallet.yaml"
data = yaml.safeLoad(string)



Round.client "http://localhost:8998/", (error, client) ->
  throw error if error
  {patchboard} = client
  {resources} = patchboard


  email = "js-test-#{Date.now()}@mail.com"
  password = "insecure"

  content = {
    email,
    wallet: data.wallet
  }

  resources.users.create content, (error, user) ->
    throw error if error
    #console.log user
    patchboard.context.authorize "Gem-User", {user_token: user.auth_token}
    console.log patchboard.context


  resources.developers.create {email, password}, (error, developer) ->
    throw error if error

    patchboard.context.authorize "Basic", {login: email, password}

    developer.get (error, result) ->
      throw error if error
      #console.log result






