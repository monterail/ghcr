"use strict"

new class GHCR
  constructor: ->
    return unless document.location.href.match(/github\.com/)

    @bindNotificationClose()

    observer = new MutationObserver =>
      if @currentUrl != Page.path()
        @currentUrl = Page.path()
        @onLocationChange()

    observer.observe $('#js-repo-pjax-container')[0], childList: true

    @currentUrl = Page.path()
    @onLocationChange()

  onLocationChange: ->

    @render()

    chunks = Page.path().split("/")
    @repo = "#{chunks[1]}/#{chunks[2]}"

    if User.authorized
      User.api.on 'unauthorized', =>
        Page.save('access_token', '')
        @notification('You are wonderful being. You also have been disauthorized from GHCR.')

      @repository = new Repository(@repo)
      @repository.attributes().then (repo) =>
        @render(repo)

        if Page.hash() == 'pending'
          @renderCommits("Pending", repo.pending)
        else if Page.hash() == 'rejected'
          @renderCommits("Rejected", repo.rejected)
        else if chunks[3] == 'commit'
          @repository.commit(chunks[4])
            .then(
              (commit) => @renderMenu(commit)
              => @notification("There is no such commit in GHCR database")
            )
        else if chunks[3] == 'commits'
          @commitsPage()
        else if chunks[3] == 'settings'
          @adminPage(repo)

  notification: ($message) =>
    @closeNotification()
    $box = Template.notification()
    $box.find('.flash-notice').append($message)
    $(".site").prepend($box)

  bindNotificationClose: ->
    $('.site').on 'click', '#ghcr-notification .close', @closeNotification

  closeNotification: ->
    $("#ghcr-notification").remove()

  render: (repo) ->
    $('#ghcr-box').remove()
    @initNav(repo.pending, repo.rejected) if repo?

  initNav: (pending = [], rejected = []) ->
    $cont = $('.repo-nav-contents')
    $('#ghcr-nav').remove()
    if User.authorized
      $ul = @renderAuthorized(pending, rejected)
    else
      $ul = @renderUnauthorized()
    $cont.prepend($ul)

  renderUnauthorized: ->
    $ul = Template.menu.nav()
    $li = Template.menu.li('Authorize')
    $a = Template.menu.a('A', 'authorize', '#696969').click (e) =>
      User.authorize()
      e.preventDefault()
      e.stopPropagation()
    $li.append($a)
    $ul.append($li)

  renderAuthorized: (pending, rejected) ->
    $ul = Template.menu.nav()

    # Pending
    $li = Template.menu.li('Pending')
    $a = Template.menu.a(pending.length, 'pending', '#69B633').click (e) =>
      if User.authorized
        Page.setLocation("/#{@repo}/commits#pending")
        @renderCommits('Pending', pending)
      else
        User.authorize()
      e.preventDefault()
      e.stopPropagation()
    $li.append($a)
    $ul.append($li)

    # rejected
    $li = Template.menu.li('Rejected')
    $a = Template.menu.a(rejected.length, 'rejected', '#B66933').click (e) =>
      if User.authorized
        Page.setLocation("/#{@repo}/commits#rejected")
        @renderCommits('Rejected', rejected)
      else
        User.authorize()
      e.preventDefault()
      e.stopPropagation()
    $li.append($a)
    $ul.append($li)

  renderCommits: (title, commits) ->
    $(".tabnav-tabs a").removeClass("selected")
    $("#ghcr-rejected-tab a").addClass("selected")
    $container = $("#js-repo-pjax-container")
    $container.empty().append(Template.commits.header(@repo, title))
    $ol = $("<ol class='commit-group'/>")
    for commit in commits
      diffUrl = "/#{@repo}/commit/#{commit.id}"
      treeUrl = "/#{@repo}/tree/#{commit.id}"

      authorNameHtml = if commit.author.username
        """<a href="/#{commit.author.username}" rel="author">#{commit.author.username}</a>"""
      else
        """<span rel="author">#{commit.author.name}</span>"""

      $ol.append(Template.commits.commit(
        commit.id, commit.message, commit.timestamp,
        diffUrl, treeUrl,
        commit.author.username || octocat, authorNameHtml
      ))
    $ol.find('time').timeago()
    $container.append($ol)

  adminPage: (repo) ->
    $box    = Template.admin.box()
    $inner  = $box.find("#ghcr_admin_inner_box")
    if repo.connected
      $inner.append(Template.admin.token(repo.token))
    else
      $btn = Template.mini_button('Connect').click (e) =>
        e.preventDefault()
        $btn.prop('disabled', true)
        User.api.connect(@repo).then =>
          Page.refresh()
      $inner.append(Template.admin.connect().prepend($btn))
    $('#options_bucket .boxed-group:nth-child(1)').after($box)

  commitsPage: ->
    ids = ($(e).data("clipboard-text") for e in $("li.commit .commit-links .js-zeroclipboard"))
    User.api.commits(@repo, {sha: ids.join(',')}).then (commits) =>
      for commit in commits
        $item = $("li.commit .commit-links .js-zeroclipboard[data-clipboard-text=#{commit.id}]").parents("li")
        commit.status ||= "pending"
        $item.addClass("ghcr__commit ghcr__commit--#{commit.status}")

  nextPending: ->
    currentId = Page.path().split('/').reverse()[0]
    User.api.next_pending(@repo, currentId).then (next) =>
      if next.id?
        Page.redirect("/#{@repo}/commit/#{next.id}")
      else
        Page.redirect("/#{@repo}")

  generateBtn: (commit, btn) ->
    Template.mini_button(btn.label, '.ghcr__status-bar__button').click () =>
      if btn.status == 'next'
        @nextPending()
      else
        commit.status = btn.status
        commit.reviewer = User.username
        User.api.save(@repo, commit.id, commit).then (data) =>
          if $('#ghcr-auto-next').prop('checked')
            @nextPending()
          else
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
      label: '<input type="checkbox" id="ghcr-auto-next"> Next Pending'
      status: 'next'

    oppBtns =
      accepted: rejectBtn
      rejected: acceptBtn

    $box = Template.commit.box(commit.status,
      commit.last_event.reviewer.username, commit.last_event.created_at)

    if parseInt($('#ghcr-pending-tab .counter').text(), 10) > 0
      $box.append GHCR.generateBtn(commit, nextPendingBtn)

    if commit.author.username != User.username
      if commit.status == 'pending'
        $box.append @generateBtn(commit, acceptBtn)
        $box.append @generateBtn(commit, rejectBtn)
      else
        $box.append @generateBtn(commit, oppBtns[commit.status])
    $box.append @generateBtn(commit, nextPendingBtn)

    $checkbox = $box.find('#ghcr-auto-next')
    $checkbox.prop('checked', Page.load('next_pending') == 'true')
    $checkbox.click (e) =>
      Page.save('next_pending', $checkbox.prop('checked'))
      e.stopPropagation()


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
