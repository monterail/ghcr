class GHCR

  url: "http://ghcr-staging.herokuapp.com/api/v1"
  constructor: initSettings

  # Abstract methods
  redirect: (url) ->
  get: (url, data, access_token) ->
  put: (url, data, access_token) ->
  href: ->
  path: ->
  hash: (value) ->
  save: (key, value) ->
  load: (key) ->

  authorize: ->
    @redirect "#{@url}/authorize?redirect_uri=#{@href()}"

  class API

    constructor: (@browser, @url, @repo, @access_token) ->

    init: ->
      @browser.get "#{@url}/#{@repo}/github/init", {}, @access_token

    commits: (params) ->
      @browser.get "#{@url}/#{@repo}/commits", params, @access_token

    count: (params) ->
      @browser.get "#{@url}/#{@repo}/commits/count", params, @access_token

    commit: (id, params = {}) ->
      @browser.get "#{@url}/#{@repo}/commits/#{id}", params, @access_token

    save: (id, commit) ->
      @browser.put "#{@url}/#{@repo}/commits/#{id}", commit, @access_token

  onLocationChange: =>
    console.log('Location change')
    chunks = @path().split("/")
    @repo = "#{chunks[1]}/#{chunks[2]}"

    if match = (/access_token=([^&+]+)/).exec(@hash())
      @save('access_token', match[1])
      @hash('')
    
    if access_token = @load('access_token')
      @api = new API(@url, @repo, access_token)
      @initTabs()

      if chunks[3] == 'commits'
        if @hash() == 'ghcr-pending'
          @renderPending()
        else if @hash() == 'ghcr-rejected'
          @renderRejected()
      else if chunks[3] == 'commit'
        @api.commit(chunks[4]).then (commit) =>
          commit.id     ||= id
          commit.status ||= "pending"
          @renderMenu(commit)

  initTabs: ->
    @api.init().then (res) =>
      @username = res.user
      @initPendingTab(res.pending_count)
      @initRejectedTab(res.rejected_count)

  initPendingTab: (count) ->
      $("li#ghcr-pending-tab").remove()
      $ul = $("div.repository-with-sidebar div.overall-summary ul.numbers-summary")
      if $ul.find("li.commits").length
        $li = $("<li id='ghcr-pending-tab' />")
        # js-selected-navigation-item tabnav-tab
        $a = $("<a href='#ghcr-pending'><span class='num'>#{count}</span> Pending</a>").click () => @renderPending()
        $li.append($a)
        $ul.append($li)
      $('#ghcr-box button.next').remove() if count == 0

  initRejectedTab: (count) ->
      $("li#ghcr-rejected-tab").remove()
      $ul = $("div.repository-with-sidebar div.overall-summary ul.numbers-summary")
      if $ul.find("li.commits").length
        $li = $("<li id='ghcr-rejected-tab' />")
        # js-selected-navigation-item tabnav-tab
        $a = $("<a href='#ghcr-rejected'><span class='num'>#{count}</span> Rejected</a>").click () => @renderRejected()
        $li.append($a)
        $ul.append($li)

  initSettings: ->
    $("li#ghcr-settings").remove()
    $ul = $('.repo-nav-contents .repo-menu:last')
    $li = $("<li class='tooltipped leftwards' id='ghcr-settings' />")
    $a = $("<a href='' class=''><span class='octicon'>G</span> <span class='full-word'>Authorize GHCR</span></a>").click (e) =>
      e.preventDefault()
      @authorize()
    $li.append($a)
    $ul.append($li)

  renderPending: ->
    @api.commits(status: 'pending', author: "!#{@username}").then (commits) =>
      $(".tabnav-tabs a").removeClass("selected")
      $("#ghcr-pending-tab a").addClass("selected")
      $container = $("#js-repo-pjax-container")
      $container.html("""
        <h3 class="commit-group-heading">Pending commits</h3>
      """)
      $ol = $("<ol class='commit-group'/>")
      @renderCommits($ol, commits)
      $container.append($ol)

  renderRejected: ->
    @api.commits(status: 'rejected', author: @username).then (commits) =>
      $(".tabnav-tabs a").removeClass("selected")
      $("#ghcr-rejected-tab a").addClass("selected")
      $container = $("#js-repo-pjax-container")
      $container.html("""
        <h3 class="commit-group-heading">Rejected commits</h3>
      """)
      $ol = $("<ol class='commit-group'/>")
      @renderCommits($ol, commits)
      $container.append($ol)

  renderCommits: ($ol, commits) ->
    for commit in commits
      diffUrl = "/#{@repo}/commit/#{commit.id}"
      treeUrl = "/#{@repo}/tree/#{commit.id}"

      authorNameHtml = if commit.author.username
        """<a href="/#{commit.author.username}" rel="author">#{commit.author.username}</a>"""
      else
        """<span rel="author">#{commit.author.name}</span>"""

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
              <span class="author-name">#{authorNameHtml}</span>
              authored <time class="js-relative-date" datetime="#{commit.timestamp}" title="#{commit.timestamp}"></time>
            </div>
          </div>
        </li>
      """))
    $ol.find('time').timeago()

  commitsPage: ->
    ids = ($(e).data("clipboard-text") for e in $("li.commit .commit-links .js-zeroclipboard"))
    @api.commits(ids).then (commits) =>
      for commit in commits
        $item = $("li.commit .commit-links .js-zeroclipboard[data-clipboard-text=#{commit.id}]").parents("li")
        commit.status ||= "pending"
        $item.addClass("ghcr__commit ghcr__commit--#{commit.status}")

  generateBtn: (commit, btn) ->
    $btn = $("<button class='minibutton .ghcr__status-bar__button'>#{btn.label}</button>").click () =>
      if btn.status == 'next'
        @api.commits(author: "!#{@username}", status: 'pending').then (commits) =>
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
        @api.save(commit.id, commit).then (data) =>
          @initTabs => @renderMenu(data)
    $btn

  renderMenu: (commit = {}) ->
    commit.author =
      name:     commit.author.name
      username: commit.author.username
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
        info = "Commit <b>accepted</b> by <a href='https://github.com/#{commit.reviewer}'>#{commit.reviewer}<a/> at #{strftime('%R, %d %b %Y', new Date(commit.updated_at))}"
      when "rejected"
        btn = acceptBtn
        info = "Commit <b>rejected</b> by <a href='https://github.com/#{commit.reviewer}'>#{commit.reviewer}<a/> at #{strftime('%R, %d %b %Y', new Date(commit.updated_at))}"
      else # pending
        info = "Code review pending"

    $box = $("<div id='ghcr-box' class='ghcr__status-bar ghcr__status-bar--#{commit.status}'><span>#{info}</span></div>")
    if parseInt($('#ghcr-pending-tab .counter').text(), 10) > 0
      $box.append GHCR.generateBtn(commit, nextPendingBtn)

    if (commit.author.username || commit.author.name) != @username
      if commit.status == 'pending'
        $box.append GHCR.generateBtn(commit, acceptBtn)
        $box.append GHCR.generateBtn(commit, rejectBtn)
      else
        $box.append GHCR.generateBtn(commit, btn)

    $(".repo-container").prepend($box)

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
