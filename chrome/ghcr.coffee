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

GHCR =
  init: (repo) ->
    @repo = repo
    @api  = API(@getApiUrl(), repo)
    @user = $.trim($("#user-links .name").text())
    @initPendingTab()
    @initRejectedTab()
    @initSettings()
    @initNotify()

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
      $ul = $("div.tabnav > ul.tabnav-tabs")
      if $ul.find("a.tabnav-tab:contains('Commits')").length
        $li = $("<li id='ghcr-pending-tab' />")
        # js-selected-navigation-item tabnav-tab
        $a = $("<a href='#ghcr-pending'  class='tabnav-tab'>Pending<span class='counter'>#{res.count}</span></a>").click () => @pending()
        $li.append($a)
        $ul.append($li)
        $('#ghcr-box button.next').remove() if res.count == 0

  initRejectedTab: ->
    @api.rejectedCount @user, (res) =>
      $("li#ghcr-rejected-tab").remove()
      $ul = $("div.tabnav > ul.tabnav-tabs")
      if $ul.find("a.tabnav-tab:contains('Commits')").length
        $li = $("<li id='ghcr-rejected-tab' />")
        # js-selected-navigation-item tabnav-tab
        $a = $("<a href='#ghcr-rejected'  class='tabnav-tab'>Rejected<span class='counter'>#{res.count}</span></a>").click () => @rejected()
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

  initNotify: ->
    $("li#ghcr-notify").remove()
    $ul = $('ul.pagehead-actions')
    $li = $("<li id='ghcr-notify' />")
    @api.notify @user, 'status', (data) =>
      enabled = data['enabled']
      btnlbl = (e) ->
        if e then "Unnotify" else "Notify"
      action = (e) ->
        if e then "disable" else "enable"
      $a = $("<a href='' class='button minibutton'>#{btnlbl(enabled)}</a>").click (e) =>
        e.preventDefault()
        @api.notify @user, action(enabled), null
        enabled = !enabled
        $(e.target).text(btnlbl(enabled))

      $li.append($a)
      $ul.prepend($li)

  pending: ->
    @api.pending @user, (commits) =>
      $(".tabnav-tabs a").removeClass("selected")
      $("#ghcr-pending-tab a").addClass("selected")
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
                authored <time class="js-relative-date" datetime="#{commit.timestamp}" title="#{commit.timestamp}"></time>
              </div>
            </div>
          </li>
        """))

      $ol.find('time').timeago()
      $container.append($ol)

  rejected: ->
    @api.rejected @user, (commits) =>
      $(".tabnav-tabs a").removeClass("selected")
      $("#ghcr-rejected-tab a").addClass("selected")
      $container = $("#js-repo-pjax-container")
      $container.html("""
        <h3 class="commit-group-heading">Rejected commits</h3>
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
                authored <time class="js-relative-date" datetime="#{commit.timestamp}" title="#{commit.timestamp}"></time>
              </div>
            </div>
          </li>
        """))

      $ol.find('time').timeago()
      $container.append($ol)

  commitsPage: ->
    ids = ($(e).data("clipboard-text") for e in $("li.commit .commit-links .js-zeroclipboard"))
    @api.commits ids, (commits) ->
      for commit in commits
        $item = $("li.commit .commit-links .js-zeroclipboard[data-clipboard-text=#{commit.id}]").parents("li")
        commit.status ||= "pending"
        $item.addClass("ghcr-#{commit.status}")

  generateBtn: (commit, btn) ->
    $btn = $("<button class='minibutton #{btn.status}'>#{btn.label}</button>").click () =>
      if btn.status == 'next'
        @api.pending @user, (commits) =>
          currentId = window.location.pathname.split('/').reverse()[0]
          nextCommit = commits[0]
          commitSize = commits.length
          for index in [0..(commitSize-1)]
            if commits[index].id == currentId
              nextCommit = commits[index+1] if index + 1 < commitSize
              break
          window.location = "/#{@repo}/commit/#{nextCommit.id}"
      else
        commit.status = btn.status
        commit.reviewer = @user
        @api.save commit, (data) =>
          @initPendingTab()
          @initRejectedTab()
          @renderMenu(data)
    $btn

  renderMenu: (commit = {}) ->
    commit.author  = $.trim($(".commit-meta .author-name").text())
    commit.message = $.trim($(".commit > .commit-title").text())
    $("#ghcr-box").remove()

    rejectBtn =
      label: 'Reject'
      status: 'rejected'

    acceptBtn =
      label: 'Accept'
      status: 'accepted'

    nextPendingBtn =
      label: 'Next Pending'
      status: 'next'

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
    if parseInt($('#ghcr-pending-tab .counter').text(), 10) > 0
      $box.append GHCR.generateBtn(commit, nextPendingBtn)

    if @user != commit.author
      if commit.status == 'pending'
        $box.append GHCR.generateBtn(commit, acceptBtn)
        $box.append GHCR.generateBtn(commit, rejectBtn)
      else
        $box.append GHCR.generateBtn(commit, btn)

    $("#js-repo-pjax-container").prepend($box)

    # sticky header
    stickyHeader =
      top: $box.offset().top
      width: $box.width()
    setStickyHeader = ->
      if $(window).scrollTop() > stickyHeader.top
        $("#ghcr-box").css
          position: "fixed"
          top: "0px"
          width: stickyHeader.width
      else
        $("#ghcr-box").css
          position: "static"
          top: "0px"
          width: stickyHeader.width
    setStickyHeader()
    $(window).scroll -> setStickyHeader()

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
  else if window.location.hash == "#ghcr-rejected"
    GHCR.rejected()
  else
    switch chunks[3]
      when "commits" # Commit History page
        GHCR.commitsPage()
      when "commit" # Commit details page
        GHCR.commitPage(chunks[4])
