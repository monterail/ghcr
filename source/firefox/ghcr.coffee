API = (url, repo, access_token) ->
  sendRequest: (type, url, data, cb) ->
    callMe = Math.random().toString(36).substring(7)
    self.port.on callMe, cb
    self.port.emit "request:#{type}", url, decodeURIComponent($.param(data)), callMe

  init: (cb) ->
    @sendRequest "get", "#{url}/#{repo}/github/init", {access_token}, cb
  commits: (params, cb) ->
    @sendRequest "get", "#{url}/#{repo}/commits", $.extend({access_token}, params), cb
  count: (params, cb) ->
    @sendRequest "get", "#{url}/#{repo}/commits/count", $.extend({access_token}, params), cb
  commit: (id, cb) ->
    @sendRequest "get", "#{url}/#{repo}/commits/#{id}", {access_token}, cb
  rejected: (user, cb) ->
    @sendRequest 'get', "#{url}/#{repo}/commits", {access_token, status:"rejected", author:user}, cb
  pending: (user, cb) ->
    @sendRequest 'get', "#{url}/#{repo}/commits", {access_token, status:"pending", author:"!#{user}"}, cb
  save: (id, data, cb) ->
    @sendRequest "put", "#{url}/#{repo}/#{id}", data, cb

API.authorize = (url) ->
  document.location = "#{url}/authorize?redirect_uri=#{document.location.href}"

init = ->
  chunks = window.location.pathname.split("/")
  repo = "#{chunks[1]}/#{chunks[2]}"

  GHCR.init repo, ->
    if window.location.hash == "#ghcr-pending"
      GHCR.pending()
    else if window.location.hash == "#ghcr-rejected"
      GHCR.rejected()
    else
      switch chunks[3]
        when "commits" # Commit History page
          GHCR.commitsPage()
        when "commit" # Commit details page
          GHCR.commitPage(chunks[4])

self.port.on "init", init

XHR = unsafeWindow.XMLHttpRequest
legacySend = XMLHttpRequest.prototype.send

XHR.prototype.send = ->
  legacyORSC = @onreadystatechange
  @onreadystatechange = ->
    if @readyState == 4 && @getResponseHeader("X-PJAX-VERSION")?
      setTimeout(init, 100)
    legacyORSC.apply(this, arguments) if legacyORSC?
  legacySend.apply(this, arguments)
