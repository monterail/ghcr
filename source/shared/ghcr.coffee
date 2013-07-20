GHCR =
  init: (@repo, cb) ->
    match = (/access_token=([^&+]+)/).exec(document.location.hash)
    if match? && match[1]?
      @setAuthToken(match[1])
      @removeHash()

    if @getAuthToken()?
      @api = API(@getApiUrl(), repo, @getAuthToken())
      @initTabs(cb)
    else
      cb

    @initSettings()

  removeHash: ->
    scrollV = undefined
    scrollH = undefined
    loc = window.location
    if "pushState" of history
      history.pushState("", document.title, loc.pathname + loc.search)
    else
      # Prevent scrolling by storing the page's current scroll offset
      scrollV = document.body.scrollTop
      scrollH = document.body.scrollLeft
      loc.hash = ""

      # Restore the scroll offset, should be flicker free
      document.body.scrollTop = scrollV
      document.body.scrollLeft = scrollH

  setAuthToken: (authToken) ->
    $.cookie('ghcr_auth_token', authToken, path: '/')

  getAuthToken: ->
    $.cookie('ghcr_auth_token')

  getApiUrl: ->
    "http://ghcr-staging.herokuapp.com/api/v1"

  setApiUrl: ->
    newApiUrl = prompt("Set ghcr api url:", @getApiUrl())
    if $.trim(newApiUrl) == ""
      @getApiUrl()
    else
      localStorage.setItem('ghcr:apiUrl', newApiUrl)
      window.location.reload()
      newApiUrl

  setUser: (username) ->
    @user = username

  initTabs: (cb) ->
    @api.init (res) =>
      @setUser(res.user)
      @initPendingTab(res.pending_count)
      @initRejectedTab(res.rejected_count)
      cb()

  initPendingTab: (count) ->
      $("li#ghcr-pending-tab").remove()
      $ul = $("div.repository-with-sidebar div.overall-summary ul.numbers-summary")
      if $ul.find("li.commits").length
        $li = $("<li id='ghcr-pending-tab' />")
        # js-selected-navigation-item tabnav-tab
        $a = $("<a href='#ghcr-pending'><span class='num'>#{count}</span> Pending</a>").click () => @pending()
        $li.append($a)
        $ul.append($li)
      $('#ghcr-box button.next').remove() if count == 0

  initRejectedTab: (count) ->
      $("li#ghcr-rejected-tab").remove()
      $ul = $("div.repository-with-sidebar div.overall-summary ul.numbers-summary")
      if $ul.find("li.commits").length
        $li = $("<li id='ghcr-rejected-tab' />")
        # js-selected-navigation-item tabnav-tab
        $a = $("<a href='#ghcr-rejected'><span class='num'>#{count}</span> Rejected</a>").click () => @rejected()
        $li.append($a)
        $ul.append($li)

  initSettings: ->
    $("li#ghcr-settings").remove()
    $ul = $('.repo-nav-contents .repo-menu:last')
    $li = $("<li class='tooltipped leftwards' id='ghcr-settings' />")
    $a = $("<a href='' class=''><span class='octicon'>G</span> <span class='full-word'>Authorize GHCR</span></a>").click (e) =>
      e.preventDefault()
      API.authorize(@getApiUrl())
    $li.append($a)
    $ul.append($li)

  pending: ->
    @api.pending @user, (commits) =>
      $(".tabnav-tabs a").removeClass("selected")
      $("#ghcr-pending-tab a").addClass("selected")
      $container = $("#js-repo-pjax-container")
      $container.html("""
        <h3 class="commit-group-heading">Pending commits</h3>
      """)
      $ol = $("<ol class='commit-group'/>")
      @renderCommits($ol, commits)
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
    @api.commits ids, (commits) ->
      for commit in commits
        $item = $("li.commit .commit-links .js-zeroclipboard[data-clipboard-text=#{commit.id}]").parents("li")
        commit.status ||= "pending"
        $item.addClass("ghcr__commit ghcr__commit--#{commit.status}")

  generateBtn: (commit, btn) ->
    $btn = $("<button class='minibutton .ghcr__status-bar__button'>#{btn.label}</button>").click () =>
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
          @initTabs =>
            @renderMenu(data)
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

    if (commit.author.username || commit.author.name) != @user
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

  commitPage: (id) ->
    @api.commit id, (commit) =>
      commit.id     ||= id
      commit.status ||= "pending"
      @renderMenu(commit)
