User = new class

  constructor: ->
    if match = (/access_token=([^&+]+)/).exec(Browser.hash())
      Browser.save('access_token', match[1])
      Browser.hash('')

    @access_token = Browser.load('access_token')

    @authorized = !!@access_token

    @api = new API(@access_token) if @authorized

    @username = $('.header a.name').text().trim()

  authorize: ->
    Browser.redirect "#{API.url}/authorize?redirect_uri=#{Browser.href()}"

