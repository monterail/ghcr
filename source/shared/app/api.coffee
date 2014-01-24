class API

  RSVP.EventTarget.mixin(@prototype)

  _checkUnauthorize: (xhr) =>
    if xhr.status == 401
      @trigger('unauthorized')

  constructor: (config) ->
    @url = config['ghcr_url']
    @access_token = config['ghcr_access_token']

  initialized: ->
    @url && @access_token

  authorize: ->
    Page.redirect "#{@url}/authorize?redirect_uri=#{Page.href()}"

  user: ->
    Request.get("#{@url}/init", {}, @access_token)
      .then(undefined, @_checkUnauthorize)

  save_settings: (opts = {}) ->
    Request.put("#{@url}/settings", {users: opts}, @access_token)
      .then(undefined, @_checkUnauthorize)

  init: (repo) ->
    Request.get("#{@url}/#{repo}", {}, @access_token)
      .then(undefined, @_checkUnauthorize)

  commits: (repo, params) ->
    Request.get("#{@url}/#{repo}/commits", params, @access_token)
      .then(undefined, @_checkUnauthorize)

  commit: (repo, id, params = {}) ->
    Request.get("#{@url}/#{repo}/commits/#{id}", params, @access_token)
      .then(undefined, @_checkUnauthorize)

  next_pending: (repo, id) ->
    Request.get("#{@url}/#{repo}/commits#{"/#{id}" if id?}/next", {}, @access_token)
      .then(undefined, @_checkUnauthorize)

  connect: (repo) ->
    Request.post("#{@url}/#{repo}/connect", {}, @access_token)
      .then(undefined, @_checkUnauthorize)

  save: (repo, id, commit) ->
    Request.put("#{@url}/#{repo}/commits/#{id}", commit, @access_token)
      .then(undefined, @_checkUnauthorize)
