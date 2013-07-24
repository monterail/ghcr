class API

  RSVP.EventTarget.mixin(@prototype)

  url: "http://ghcr-staging.herokuapp.com/api/v1"

  constructor: (@repo, @access_token) ->

  authorize: ->
    Browser.redirect "#{@url}/authorize?redirect_uri=#{Browser.href()}"

  authorized: -> !!@access_token

  init: (repo) ->
    Request.get("#{@url}/#{repo}", {}, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  commits: (repo, params) ->
    Request.get("#{@url}/#{repo}/commits", params, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  commit: (repo, id, params = {}) ->
    Request.get("#{@url}/#{repo}/commits/#{id}", params, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  connect: (repo) ->
    Request.post("#{@url}/#{repo}/connect", {}, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  save: (repo, id, commit) ->
    Request.put("#{@url}/#{repo}/commits/#{id}", commit, @access_token)
      .then(undefined, => @trigger('unauthorized'))
