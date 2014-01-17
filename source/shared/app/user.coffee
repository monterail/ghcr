User = new class

  constructor: ->
    # if match = (/access_token=([^&+]+)/).exec(Page.hash())
    #   Page.save('access_token', match[1])
    #   Page.hash('')

    # @access_token = Page.load('access_token')

    # @authorized = !!@access_token

    # @api = new API(@access_token) if @authorized

    # @username = $('.header a.name').text().trim()

  authorize: ->
    Page.redirect "#{API.url}/authorize?redirect_uri=#{Page.href()}"


Config = class
  RSVP.EventTarget.mixin(@prototype)

  init: (@config = {})->
    console.log 'config init', Page.hash()
    if match = (/access_token=([^&+]+)/).exec(Page.hash())
      console.log 'match token'
      Storage.set('ghcr_access_token', match[1]).then (value) =>
        Page.hash('')

    Storage.get('ghcr_url').then (value) =>
      @config['url'] = value
      Storage.get('ghcr_access_token').then (value) =>
        @config['access_token'] = value
        @initApi()

  initApi: =>
    if @config['url'] && @config['access_token']
      console.log 'full config', @config
      @api = new API(@config)
      @trigger('apiIsReady')

  setConfig: (key, value) =>
    Storage.set("ghcr_#{key}", value)
    @config[key] = value
    @initApi()

  authorize: ->
    Page.redirect "#{API.url}/authorize?redirect_uri=#{Page.href()}"
