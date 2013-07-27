User = new class

  constructor: ->
    if match = (/access_token=([^&+]+)/).exec(Page.hash())
      Page.save('access_token', match[1])
      Page.hash('')

    @access_token = Page.load('access_token')

    @authorized = !!@access_token

    @api = new API(@access_token) if @authorized

    @username = $('.header a.name').text().trim()

  authorize: ->
    Page.redirect "#{API.url}/authorize?redirect_uri=#{Page.href()}"

