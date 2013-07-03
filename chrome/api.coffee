API = (url, repo) ->
  commits: (ids, cb) ->
    $.post "#{url}/commits", {repo: repo, ids: ids}, cb, 'json'
  commit: (id, cb) ->
    $.getJSON "#{url}/commit", {repo: repo, id: id}, cb
  save: (data, cb) ->
    $.post "#{url}/save", $.extend({}, data, {repo: repo}), cb
  pending: (user, cb) ->
    $.get "#{url}/pending", {repo: repo, user: user}, cb, 'json'
  pendingCount: (user, cb) ->
    $.get "#{url}/pending/count", {repo: repo, user: user}, cb, 'json'
  rejected: (user, cb) ->
    $.get "#{url}/rejected", {repo: repo, user: user}, cb, 'json'
  rejectedCount: (user, cb) ->
    $.get "#{url}/rejected/count", {repo: repo, user: user}, cb, 'json'
  notify: (reviewer, action, cb) ->
    $.post "#{url}/notify", {repo: repo, action: action, reviewer: reviewer}, cb, 'json'
