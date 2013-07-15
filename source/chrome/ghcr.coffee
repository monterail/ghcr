API = (url, repo, access_token) ->
  init: (cb) ->
    $.get "#{url}/#{repo}/github/init", {access_token}, cb, 'json'
  commits: (params, cb) ->
    $.get "#{url}/#{repo}/commits", $.extend({access_token}, params), cb, 'json'
  count: (params, cb) ->
    $.get "#{url}/#{repo}/commits/count", $.extend({access_token}, params), cb, 'json'
  commit: (id, cb) ->
    $.get "#{url}/#{repo}/commits/#{id}", {access_token}, cb, 'json'
  rejected: (user, cb) ->
    $.get "#{url}/#{repo}/commits", {access_token, status:"rejected", author:user}, cb, 'json'
  pending: (user, cb) ->
    $.get "#{url}/#{repo}/commits", {access_token, status:"pending", author:"!#{user}"}, cb, 'json'
  save: (id, data, cb) ->
    $.put "#{url}/#{repo}/#{id}", data, cb

API.authorize = (url) ->
  document.location = "#{url}/authorize?redirect_uri=#{document.location.href}"

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
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
