
module.exports = class Client

  constructor: (@patchboard) ->
    @resources = @patchboard.resources


  developer: -> 
    {
      # callback takes an error and a developer
      # credentials requires email and pubkey
      # credentials can also take a privkey to authorize
      # the client as a developer
      create: (credentials, callback) =>
        @resources.developers.create credentials, (error, developer) =>
          unless @_developer?
            callback error if error
            # !!! should @_developer be saved on the client or the developer function !!!
            @_developer = developer
            if credentials.privkey
              @patchboard.context.authorize 'Gem-Developer', credentials
            # @developer.resource = @_developer
          callback null, @_developer

      # get: ->
      #   return @_developer if @_developer?
      #   throw """Must authenticate as a developer before accessing
      #           the developer resource"""
      
      # applications: ->


      # applications: () =>
      #   # console.log(@)
      #   resource = @patchboard.resources.application(@developer.resource.applications.url)
      #   resource.get()
    }









