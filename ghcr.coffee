API = (url, repo) ->
  commits: (ids, cb) ->
    $.post "#{url}/commits", {repo: repo, ids: ids}, cb, 'json'
  commit: (id, cb) ->
    $.getJSON "#{url}/commit", {repo: repo, id: id}, cb
  save: (data, cb) ->
    $.post "#{url}/save", $.extend({}, data, {repo: repo}), cb

GHCR =
  init: (apiUrl, repo) ->
    @api  = API(apiUrl, repo)
    @user = $.trim($("#user-links .name").text())
  commitsPage: ->
    ids = ($(e).data("clipboard-text") for e in $("li.commit .commit-links .js-zeroclipboard"))
    @api.commits ids, (commits) ->
      for commit in commits
        $item = $("li.commit .commit-links .js-zeroclipboard[data-clipboard-text=#{commit.id}]").parents("li")
        commit.status ||= "pending"
        $item.addClass("ghcr-#{commit.status}")
  commitPage: ->
    id = $(".full-commit .sha.js-selectable-text").text()
    render = (commit = {}) =>
      commit.status ||= "pending"
      commit.id ||= id

      switch commit.status
        when "accepted"
          fun = =>
            commit.status = "pending"
            commit.user = @user
            @api.save(commit)
            render(commit)
          btnlbl = "Make pending"
          console.log commit.created_at
          info = "Commit accepted by <a href='https://github.com/#{commit.user}'>#{commit.user}<a/> at #{commit.created_at}"
        else # pending
          fun = =>
            commit.status = "accepted"
            commit.user = @user
            @api.save(commit)
            render(commit)
          btnlbl = "Accept"
          info = "Code review pending"

      $btn = $("<button class='minibutton'>#{btnlbl}</button>").click(fun)
      $("#ghcr-box").remove()
      $box = $("<div id='ghcr-box' class='ghcr-#{commit.status}'><span>#{info}</span> </div>")
      $box.append($btn)
      $("#js-repo-pjax-container").prepend($box)

    @api.commit id, render


chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  chunks = window.location.pathname.split("/")
  repo = "#{chunks[1]}/#{chunks[2]}"
  apiUrl = 'http://localhost:9393/ghcr'

  GHCR.init(apiUrl, repo)

  switch chunks[3]
    when "commits" # Commit History page
      GHCR.commitsPage()
    when "commit" # Commit details page
      GHCR.commitPage()

