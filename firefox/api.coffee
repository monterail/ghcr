API = (url, repo) ->
  sendRequest: (type, url, data, cb) ->
    callMe = Math.random().toString(36).substring(7)
    self.port.on callMe, cb
    self.port.emit "request:#{type}", url, decodeURIComponent($.param(data)), callMe

  commits: (ids, cb) ->
    @sendRequest "post", "#{url}/commits", {repo: repo, ids: ids}, cb
  commit: (id, cb) ->
    @sendRequest "get", "#{url}/commit", {repo: repo, id: id}, cb
  save: (data, cb) ->
    @sendRequest "post", "#{url}/save", $.extend({}, data, {repo: repo}), cb
  pending: (user, cb) ->
    @sendRequest "get", "#{url}/pending", {repo: repo, user: user}, cb
  pendingCount: (user, cb) ->
    @sendRequest "get", "#{url}/pending/count", {repo: repo, user: user}, cb
  rejected: (user, cb) ->
    @sendRequest "get", "#{url}/rejected", {repo: repo, user: user}, cb
  rejectedCount: (user, cb) ->
    @sendRequest "get", "#{url}/rejected/count", {repo: repo, user: user}, cb
  notify: (reviewer, action, cb) ->
    @sendRequest "post", "#{url}/notify", {repo: repo, action: action, reviewer: reviewer}, cb
