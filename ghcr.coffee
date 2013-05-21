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

GHCR =
  init: (repo) ->
    @repo = repo
    @api  = API(@getApiUrl(), repo)
    @user = $.trim($("#user-links .name").text())
    @initPendingTab()
    @initSettings()

  getApiUrl: ->
    apiUrl = localStorage.getItem('ghcr:apiUrl')
    if $.trim(apiUrl) == "" then 'http://localhost:9393/ghcr' else apiUrl

  setApiUrl: ->
    newApiUrl = prompt("Set ghcr api url:", @getApiUrl())
    if $.trim(newApiUrl) == ""
      @getApiUrl()
    else
      localStorage.setItem('ghcr:apiUrl', newApiUrl)
      window.location.reload()
      newApiUrl

  initPendingTab: ->
    @api.pendingCount @user, (res) =>
      $("li#ghcr-pending-tab").remove()
      $ul = $("li a.tabnav-tab:contains('Commits')").parent().parent()
      $li = $("<li id='ghcr-pending-tab' />")
      # js-selected-navigation-item tabnav-tab
      $a = $("<a href='#ghcr-pending'  class='tabnav-tab'>Pending commits <span class='counter'>#{res.count}</span></a>").click () => @pending()
      $li.append($a)
      $ul.append($li)

  initSettings: ->
    $("li#ghcr-settings").remove()
    $ul = $('span.tabnav-right ul.tabnav-tabs')
    $li = $("<li id='ghcr-settings' />")
    $a = $("<a href='' class='tabnav-tab'>Set apiUrl</a>").click (e) =>
      e.preventDefault()
      @setApiUrl()
    $li.append($a)
    $ul.prepend($li)

  pending: ->
    @api.pending @user, (commits) =>
      $(".tabnav-tabs a").removeClass("selected")
      $("#ghcr-pending-tab").addClass("selected")
      $container = $("#js-repo-pjax-container")
      $container.html("""
        <h3 class="commit-group-heading">Pending commits</h3>
      """)
      $ol = $("<ol class='commit-group'/>")

      for commit in commits
        diffUrl = "/#{@repo}/commit/#{commit.id}"
        treeUrl = "/#{@repo}/tree/#{commit.id}"

        $ol.append($("""
          <li class="commit commit-group-item js-navigation-item js-details-container">
            <p class="commit-title  js-pjax-commit-title">
              <a href="#{diffUrl}" class="message">#{commit.message}</a>
            </p>
            <div class="commit-meta">
              <div class="commit-links">
                <span class="js-zeroclipboard zeroclipboard-button" data-clipboard-text="#{commit.id}" data-copied-hint="copied!" title="Copy SHA">
                  <span class="octicon octicon-clippy"></span>
                </span>

                <a href="#{diffUrl}" class="gobutton ">
                  <span class="sha">#{commit.id.substring(0,10)}
                    <span class="octicon octicon-arrow-small-right"></span>
                  </span>
                </a>

                <a href="#{treeUrl}" class="browse-button" title="Browse the code at this point in the history" rel="nofollow">
                  Browse code <span class="octicon octicon-arrow-right"></span>
                </a>
              </div>

              <div class="authorship">
                <span class="author-name"><a href="/#{commit.author.username}" rel="author">#{commit.author.username}</a></span>
                authored <time class="js-relative-date" datetime="#{commit.timestamp}" title="2013-03-17 16:56:15">2 days before the day after tomorow</time>
              </div>
            </div>
          </li>
        """))

      $container.append($ol)

  commitsPage: ->
    ids = ($(e).data("clipboard-text") for e in $("li.commit .commit-links .js-zeroclipboard"))
    @api.commits ids, (commits) ->
      for commit in commits
        $item = $("li.commit .commit-links .js-zeroclipboard[data-clipboard-text=#{commit.id}]").parents("li")
        commit.status ||= "pending"
        $item.addClass("ghcr-#{commit.status}")

  generateBtn: (commit, btn) ->
    $btn = $("<button class='minibutton'>#{btn.label}</button>").click () =>
      commit.status = btn.status
      commit.reviewer = @user
      @api.save commit, (data) =>
        @renderMenu(data)
        @initPendingTab()
    $btn

  renderMenu: (commit = {}) ->
    author = $.trim($(".commit-meta .author-name").text())
    $("#ghcr-box").remove()

    rejectBtn =
      label: 'Reject'
      status: 'rejected'

    acceptBtn =
      label: 'Accept'
      status: 'accepted'

    switch commit.status
      when "accepted"
        btn = rejectBtn
        info = "Commit accepted by <a href='https://github.com/#{commit.reviewer}'>#{commit.reviewer}<a/> at #{strftime('%R, %d %b %Y', new Date(commit.updated_at))}"
      when "rejected"
        btn = acceptBtn
        info = "Commit rejected by <a href='https://github.com/#{commit.reviewer}'>#{commit.reviewer}<a/> at #{strftime('%R, %d %b %Y', new Date(commit.updated_at))}"
      else # pending
        info = "Code review pending"

    $box = $("<div id='ghcr-box' class='ghcr-#{commit.status}'><span>#{info}</span> </div>")

    if commit.status == 'pending' and @user != author
      $box.append GHCR.generateBtn(commit, acceptBtn)
      $box.append GHCR.generateBtn(commit, rejectBtn)
    else if commit.status != 'pending'
      $box.append GHCR.generateBtn(commit, btn)
    $("#js-repo-pjax-container").prepend($box)

  commitPage: (id) ->
    @api.commit id, (commit) =>
      commit.id     ||= id
      commit.status ||= "pending"
      @renderMenu(commit)


chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  chunks = window.location.pathname.split("/")
  repo = "#{chunks[1]}/#{chunks[2]}"

  GHCR.init(repo)

  if window.location.hash == "#ghcr-pending"
    GHCR.pending()
  else
    switch chunks[3]
      when "commits" # Commit History page
        GHCR.commitsPage()
      when "commit" # Commit details page
        GHCR.commitPage(chunks[4])
