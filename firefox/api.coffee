API = (url, repo, access_token) ->
  sendRequest: (type, url, data, cb) ->
    callMe = Math.random().toString(36).substring(7)
    self.port.on callMe, cb
    self.port.emit "request:#{type}", url, decodeURIComponent($.param(data)), callMe

  commits: (params, cb) ->
    @sendRequest "get", "#{url}/#{repo}/commits", $.extend({access_token}, params), cb
  count: (params, cb) ->
    @sendRequest "get", "#{url}/#{repo}/commits/count", $.extend({access_token}, params), cb
  commit: (id, cb) ->
    @sendRequest "get", "#{url}/#{repo}/commit/#{id}", {auth_token}, cb
  save: (id, data, cb) ->
    @sendRequest "put", "#{url}/#{repo}/#{id}", data, cb


API.authorize = (url) ->
  document.location = "#{url}/authorize?redirect_uri=#{document.location.href}"
