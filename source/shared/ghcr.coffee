"use strict"

new class GHCR
  constructor: ->
    return unless document.location.href.match(/github\.com/)

    ghcrConfig = new Config()
    ghcrConfig.on 'dataChanged', (settings) =>
      @api = new API(settings)
      jQuery =>
        @github_username = $('.header a.name').text().trim()
        @onLocationChange()
    ghcrConfig.init()

    @bindNotificationClose()

    observer = new MutationObserver =>
      if @currentUrl != Page.path()
        @currentUrl = Page.path()
        @onLocationChange()
    if $('#js-repo-pjax-container').length
      observer.observe $('#js-repo-pjax-container')[0], childList: true
    @currentUrl = Page.path()

  onLocationChange: ->
    $('#ghcr-box').remove()

    chunks = Page.path().split("/")
    @repo = "#{chunks[1]}/#{chunks[2]}"

    if @api?.initialized()
      @api.on 'unauthorized', =>
        Storage.set('ghcr_access_token', null)
        @notification('You are wonderful being. You also have been disauthorized from GHCR.')

      @repository = new Repository(@repo, @api)
      if (/Page not found · GitHub/i).test(document.title) and chunks[3] == 'commit'
        @renderNotFound(@repo, chunks[4])
      else
        @repository.attributes().then (repo) =>
          @renderAuthorized(repo.pending, repo.discuss)

          if Page.hash() == 'pending'
            @renderCommits("Pending", repo.pending)
          else if Page.hash() == 'discuss'
            @renderCommits("Discuss", repo.discuss)
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
        .catch (err) =>
          @adminPage({connected: false}) if chunks[3] == 'settings'
    else
      @renderSetup()

  notification: ($message) =>
    @closeNotification()
    $box = Template.notification()
    $box.find('.flash-notice').append($message)
    $(".site").prepend($box)

  bindNotificationClose: ->
    $('.site').on 'click', '#ghcr-notification .close', @closeNotification

  closeNotification: ->
    $("#ghcr-notification").remove()

  renderNotFound: (repo, sha) ->
    $remove_commit = Template.remove_commit()
    $remove_commit.find('button').on 'click', (e) =>
      e.preventDefault()
      e.stopPropagation()
      if confirm('Are you sure?')
        @api.save(repo, sha, {status: 'removed'})
        @nextPending()

    $('#parallax_wrapper').append($remove_commit)

  renderSetup: ->
    $('#ghcr-nav').remove()
    $cont = $('.sunken-menu')
    $ul = Template.menu.nav()
    $li = Template.menu.li('Setup GHCR')
    $a = Template.menu.a('★', 'Setup GHCR', '#696969').click (e) =>
      Page.redirect(chrome.extension.getURL("settings.html"))
      e.preventDefault()
      e.stopPropagation()
    $li.append($a)
    $ul.append($li)
    $cont.prepend($ul)

  renderAuthorized: (pending, discuss) ->
    $('#ghcr-nav').remove()
    $cont = $('.sunken-menu')
    $ul = Template.menu.nav()

    # Pending
    $li = Template.menu.li('Pending').attr(id: 'ghcr-pending-tab')
    $a = Template.menu.a(pending.length, 'pending', '#69B633').click (e) =>
      if @api?.initialized()
        Page.setLocation("/#{@repo}/commits#pending")
        @renderCommits('Pending', pending)
      else
        @api.authorize()
      e.preventDefault()
      e.stopPropagation()
    $li.append($a)
    $ul.append($li)
    $cont.prepend($ul)

    # discuss
    $li = Template.menu.li('Discuss').attr(id: 'ghcr-discuss-tab')
    $a = Template.menu.a(discuss.length, 'discuss', '#B66933').click (e) =>
      if @api?.initialized()
        Page.setLocation("/#{@repo}/commits#discuss")
        @renderCommits('Discuss', discuss)
      else
        @api.authorize()
      e.preventDefault()
      e.stopPropagation()
    $li.append($a)
    $ul.append($li)

  renderCommits: (title, commits) ->
    $(".sunken-menu-group a").removeClass("selected")
    $("#ghcr-#{title.toLowerCase()}-tab a").addClass("selected")
    $container = $("#js-repo-pjax-container")
    $container.empty().append(Template.commits.header(@repo, title))
    $ol = $("<ol class='commit-group table-list table-list-bordered'/>")
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
        commit.author.username || 'octocat', authorNameHtml
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
        @api.connect(@repo).then =>
          Page.refresh()
      $inner.append(Template.admin.connect().prepend($btn))
    $('#options_bucket .boxed-group:nth-child(1)').after($box)

  commitsPage: ->
    ids = ($(e).data("clipboard-text") for e in $("li.commit .commit-links .js-zeroclipboard"))
    @api.commits(@repo, {sha: ids.join(',')}).then (commits) =>
      for commit in commits
        $item = $("li.commits-list-item[data-channel='#{@repo}:commit:#{commit.id}']")
        commit.status ||= "pending"
        $item.addClass("ghcr__commit ghcr__commit--#{commit.status}")

  nextPending: ->
    currentId = Page.path().split('/').reverse()[0]
    @api.next_pending(@repo, currentId).then (next) =>
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
        commit.reviewer = @github_username
        @api.save(@repo, commit.id, commit).then (data) =>
          if $('#ghcr-auto-next').prop('checked')
            @nextPending()
          else
            @renderMenu(data)

  renderMenu: (commit = {}) ->
    # TODO: looks wired problay can remove it
    # commit.author =
    #   name:     commit.author.name
    #   username: commit.author.username

    commit.message = $.trim($(".commit > .commit-title").text())

    $("#ghcr-box").remove()

    discussBtn =
      label: 'Discuss'
      status: 'discuss'
    acceptBtn =
      label: 'Accept'
      status: 'accepted'
    nextPendingBtn =
      label: '<input type="checkbox" id="ghcr-auto-next"> Next Pending'
      status: 'next'

    oppBtns =
      accepted: discussBtn
      discuss: acceptBtn

    $box = Template.commit.box(commit.status,
      commit.last_event.reviewer.username, commit.last_event.created_at)

    if parseInt($('#ghcr-pending-tab .counter').text(), 10) > 0
      $box.append GHCR.generateBtn(commit, nextPendingBtn)

    if commit.committer.username != @github_username
      if commit.status == 'pending'
        $box.append @generateBtn(commit, acceptBtn)
        $box.append @generateBtn(commit, discussBtn)
      else if ['accepted', 'discuss'].indexOf(commit.status) > -1
        $box.append @generateBtn(commit, oppBtns[commit.status])
    $box.append @generateBtn(commit, nextPendingBtn)

    $checkbox = $box.find('#ghcr-auto-next')
    Storage.get('ghcr_next_pending').then (value) =>
      $checkbox.prop('checked', value)
    $checkbox.click (e) =>
      Storage.set('ghcr_next_pending', $checkbox.prop('checked'))
      e.stopPropagation()
    $(".repo-container").prepend($box)

    # sticky header
    stickyHeader =
      top: $box.offset().top
      width: "920px"
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
