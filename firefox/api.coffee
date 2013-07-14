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
    @sendRequest "get", "#{url}/#{repo}/commit/#{id}", {access_token}, cb
  rejected: (user, cb) ->
    @sendRequest 'get', "#{url}/#{repo}/commits", {access_token, status:"rejected", author:user}, cb
  pending: (user, cb) ->
    @sendRequest 'get', "#{url}/#{repo}/commits", {access_token, status:"pending", author:"!#{user}"}, cb
  save: (id, data, cb) ->
    @sendRequest "put", "#{url}/#{repo}/#{id}", data, cb


API.authorize = (url) ->
  document.location = "#{url}/authorize?redirect_uri=#{document.location.href}"
