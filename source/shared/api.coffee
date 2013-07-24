class API

  RSVP.EventTarget.mixin(@prototype)

  url: "http://ghcr-staging.herokuapp.com/api/v1"

  constructor: (@browser, @repo, @access_token) ->

  authorize: ->
    @browser.redirect "#{@url}/authorize?redirect_uri=#{@browser.href()}"

  authorized: -> !!@access_token

  init: (repo) ->
    @browser.get("#{@url}/#{repo}", {}, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  commits: (repo, params) ->
    @browser.get("#{@url}/#{repo}/commits", params, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  commit: (repo, id, params = {}) ->
    @browser.get("#{@url}/#{repo}/commits/#{id}", params, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  connect: (repo) ->
    @browser.post("#{@url}/#{repo}/connect", {}, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  save: (repo, id, commit) ->
    @browser.put("#{@url}/#{repo}/commits/#{id}", commit, @access_token)
      .then(undefined, => @trigger('unauthorized'))
