class API

  @url = "http://ghcr-staging.herokuapp.com/api/v1"

  RSVP.EventTarget.mixin(@prototype)

  constructor: (@access_token) ->

  init: (repo) ->
    Request.get("#{API.url}/#{repo}", {}, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  commits: (repo, params) ->
    Request.get("#{API.url}/#{repo}/commits", params, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  commit: (repo, id, params = {}) ->
    Request.get("#{API.url}/#{repo}/commits/#{id}", params, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  next_pending: (repo) ->
    Request.get("#{API.url}/#{repo}/commits/next", {}, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  connect: (repo) ->
    Request.post("#{API.url}/#{repo}/connect", {}, @access_token)
      .then(undefined, => @trigger('unauthorized'))

  save: (repo, id, commit) ->
    Request.put("#{API.url}/#{repo}/commits/#{id}", commit, @access_token)
      .then(undefined, => @trigger('unauthorized'))
