"use strict";

class GHCR

  url: "http://ghcr-staging.herokuapp.com/api/v1"

  constructor: ->
    @username = $('.header a.name').text().trim()

    # Authorization
    if match = (/access_token=([^&+]+)/).exec(@browser.hash())
      @browser.save('access_token', match[1])
      @browser.hash('')
    
    observer = new MutationObserver => @onLocationChange()
    observer.observe $('#js-repo-pjax-container')[0], childList: true
    @onLocationChange()

  class API

    constructor: (@browser, @url, @repo, @access_token) ->

    init: ->
      @browser.get "#{@url}/#{@repo}", {}, @access_token

    commits: (params) ->
      @browser.get "#{@url}/#{@repo}/commits", params, @access_token

    commit: (id, params = {}) ->
      @browser.get "#{@url}/#{@repo}/commits/#{id}", params, @access_token

    connect: ->
      @browser.post "#{@url}/#{@repo}/connect", {}, @access_token

    save: (id, commit) ->
      @browser.put "#{@url}/#{@repo}/commits/#{id}", commit, @access_token

  authorize: (state = "") ->
    @browser.save('state', state)
    @browser.redirect "#{@url}/authorize?redirect_uri=#{@browser.href()}&state=#{state}"

  onLocationChange: ->
    @render()

    chunks = @browser.path().split("/")
    @repo = "#{chunks[1]}/#{chunks[2]}"

    if access_token = @browser.load('access_token')
      @api = new API(@browser, @url, @repo, access_token)

      @api.init().then (repo) => @render(repo)

      if chunks[3] == 'commit'
        @api.commit(chunks[4]).then (commit) =>
          commit.id     ||= id
          commit.status ||= "pending"
          @renderMenu(commit)

      if @browser.load('state') == 'pending'
        @browser.save('state', '')
        @renderPending()

      if @browser.load('state') == 'rejected'
        @browser.save('state', '')
        @renderRejected()

  notification: ($message) ->
    $("#ghcr-notification").remove()
    $box = $("<div id='ghcr-notification' class='flash-messages container'><div class='flash flash-notice'><span class='octicon octicon-remove-close close'></span> </div></div>")
    $box.find('.flash-notice').append($message)
    $(".site").prepend($box)

  render: (repo) ->

    $('#ghcr-box').remove()

    if repo?
      if !repo.connected
        if repo.admin
          $btn = $("<button class='minibutton'>Connect</button>").click (e) =>
            e.preventDefault()
            $btn.prop('disabled', true)

            @api.connect().then =>
              @notification 'Successfully connected to Github Code Review! 
                            New commits will be added to review queue.'

          @notification($('<div> this repository to Github Code Review</div>').prepend($btn))
        else
          @notification('Please ask an admin of this repository to connect Github Code Review.')
      else
        @initNav(repo.pending.length, repo.rejected.length)
    else
      @initNav()

  initNav: (pendingCount = 0, rejectedCount = 0) ->
    $cont = $('.repo-nav-contents')
    $('#ghcr-nav').remove()
    $ul = $('<ul id="ghcr-nav" class="repo-menu"/>')
    $cont.prepend($ul)

    if pendingCount?
      $li = $("<li class='tooltipped leftwards' id='ghcr-pending' original-title='Pending' />")
      $a = $("<a href='#{@browser.path()}#ghcr-pending' class=''><span style='background-color: #69B633; padding: 2px 4px; color: white; border-radius: 3px'>#{pendingCount}</span> <span class='full-word'>pending</span></a>").click (e) =>
        if @api?
          @renderPending()
        else
          @authorize('pending')
        e.preventDefault()
      $li.append($a)
      $ul.append($li)

    if rejectedCount?
      $li = $("<li class='tooltipped leftwards' id='ghcr-rejected' original-title='Rejected' />")
      $a = $("<a href='#{@browser.path()}#ghcr-rejected' class=''><span style='background-color: #B66933; padding: 2px 4px; color: white; border-radius: 3px'>#{rejectedCount}</span> <span class='full-word'>rejected</span></a>").click (e) =>
        if @api?
          @renderRejected()
        else
          @authorize('rejected')
        e.preventDefault()
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
    $("<button class='minibutton .ghcr__status-bar__button'>#{btn.label}</button>").click () =>
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
        commit.reviewer = @username
        @api.save(commit.id, commit).then (data) =>
          @renderMenu(data)

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
        info = "Commit <b>accepted</b> by <a href='https://github.com/#{commit.last_event.reviewer.username}'>#{commit.last_event.reviewer.username}<a/> at #{strftime('%R, %d %b %Y', new Date(commit.last_event.created_at))}"
      when "rejected"
        btn = acceptBtn
        info = "Commit <b>rejected</b> by <a href='https://github.com/#{commit.last_event.reviewer.username}'>#{commit.last_event.reviewer.username}<a/> at #{strftime('%R, %d %b %Y', new Date(commit.last_event.created_at))}"
      else # pending
        info = "Code review pending"

    $box = $("<div id='ghcr-box' class='ghcr__status-bar ghcr__status-bar--#{commit.status}'><span>#{info}</span></div>")

    if parseInt($('#ghcr-pending-tab .counter').text(), 10) > 0
      $box.append GHCR.generateBtn(commit, nextPendingBtn)

    if commit.author.username != @username
        $box.append @generateBtn(commit, acceptBtn)
        $box.append @generateBtn(commit, rejectBtn)
      else
        $box.append @generateBtn(commit, btn)

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
