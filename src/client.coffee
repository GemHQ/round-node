
module.exports = class Client

  constructor: (@patchboard) ->
    @resources = @patchboard.resources


  developer: (callback) -> 
    console.log @
    callback @_developer if @_developer
    
    @resources.developers.get (error, developer) =>
      callback error if error

      @_developer = developer
      callback null, @_developer
      

  developers: ->
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
            # !!! this is being set on create. Should it be set on authorize instead? !!!
            @_developer = developer
            if credentials.privkey
              @patchboard.context.authorize 'Gem-Developer', credentials
            # @developer.resource = @_developer
          callback null, @_developer

      authorize: (credentials) =>
        @patchboard.context.authorize 'Gem-Developer', credentials
        @patchboard.resources.developer(credentials.email)


      # get: ->
      #   return @_developer if @_developer?
      #   throw """Must authenticate as a developer before accessing
      #           the developer resource"""
      
      applications: =>
         return @_developer.applications if @_developer
         throw 'Must authenticate as a developer first.'


      # applications: () =>
      #   # console.log(@)
      #   resource = @patchboard.resources.application(@developer.resource.applications.url)
      #   resource.get()
    }









