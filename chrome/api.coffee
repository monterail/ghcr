API = (url, repo, access_token) ->
  commits: (params, cb) ->
    $.get "#{url}/#{repo}/commits", $.extend({access_token}, params), cb, 'json'
  count: (params, cb) ->
    $.get "#{url}/#{repo}/commits/count", $.extend({access_token}, params), cb, 'json'
  commit: (id, cb) ->
    $.get "#{url}/#{repo}/commit/#{id}", {auth_token}, cb, 'json'
  save: (id, data, cb) ->
    $.put "#{url}/#{repo}/#{id}", data, cb

API.authorize = (url) ->
  document.location = "#{url}/authorize?redirect_uri=#{document.location.href}"
