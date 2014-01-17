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

  init: ->
    console.log 'config init', Page.hash()
    if match = (/access_token=([^&+]+)/).exec(Page.hash())
      console.log 'match token'
      Storage.set('ghcr_access_token', match[1]).then (value) =>
        Page.hash('')

    Storage.get('ghcr_access_token').then @initApi

  initApi: (value) =>
    console.log 'init API with token:', value
    @api = new API(value)
    @trigger('apiIsReady') if !!value

  authorize: ->
    Page.redirect "#{API.url}/authorize?redirect_uri=#{Page.href()}"
