Patchboard = require "patchboard-js"

Context = require "./context"
Client = require "./client"


gem_url = "https://api.gem.co/"

module.exports = {

  url: gem_url

  client: (url=gem_url, callback) ->
    if @patchboard?
      callback null, new Client(@patchboard)
    else
      Patchboard.discover url, {context: Context}, (error, @patchboard) =>
        if error
          callback error
        else
          callback null, new Client(@patchboard)

}


