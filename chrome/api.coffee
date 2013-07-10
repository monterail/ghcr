API = (url, repo) ->
  root = "#{url}/api/v1"

  commits: (ids, cb) ->
    $.post "#{root}/commits", {repo: repo, ids: ids}, cb, 'json'
  commit: (id, cb) ->
    $.getJSON "#{root}/commit", {repo: repo, id: id}, cb
  save: (data, cb) ->
    $.post "#{root}/save", $.extend({}, data, {repo: repo}), cb
  pending: (user, cb) ->
    $.get "#{root}/pending", {repo: repo, user: user}, cb, 'json'
  pendingCount: (user, cb) ->
    $.get "#{root}/pending/count", {repo: repo, user: user}, cb, 'json'
  rejected: (user, cb) ->
    $.get "#{root}/rejected", {repo: repo, user: user}, cb, 'json'
  rejectedCount: (user, cb) ->
    $.get "#{root}/rejected/count", {repo: repo, user: user}, cb, 'json'
  notify: (reviewer, action, cb) ->
    $.post "#{root}/notify", {repo: repo, action: action, reviewer: reviewer}, cb, 'json'
