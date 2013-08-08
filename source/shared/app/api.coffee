class API

  @url = "http://ghcr-staging.herokuapp.com/api/v1"

  RSVP.EventTarget.mixin(@prototype)

  _checkUnauthorize: (xhr) =>
    if xhr.status == 401
      @trigger('unauthorized')

  constructor: (@access_token) ->

  init: (repo) ->
    Request.get("#{API.url}/#{repo}", {}, @access_token)
      .then(undefined, @_checkUnauthorize)

  commits: (repo, params) ->
    Request.get("#{API.url}/#{repo}/commits", params, @access_token)
      .then(undefined, @_checkUnauthorize)

  commit: (repo, id, params = {}) ->
    Request.get("#{API.url}/#{repo}/commits/#{id}", params, @access_token)
      .then(undefined, @_checkUnauthorize)

  next_pending: (repo, id) ->
    Request.get("#{API.url}/#{repo}/commits#{"/#{id}" if id?}/next", {}, @access_token)
      .then(undefined, @_checkUnauthorize)

  connect: (repo) ->
    Request.post("#{API.url}/#{repo}/connect", {}, @access_token)
      .then(undefined, @_checkUnauthorize)

  save: (repo, id, commit) ->
    Request.put("#{API.url}/#{repo}/commits/#{id}", commit, @access_token)
      .then(undefined, @_checkUnauthorize)
