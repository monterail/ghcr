"use strict"

class GHCR
  constructor: ->
    @username = $('.header a.name').text().trim()
    @bindNotificationClose()

    # Authorization
    if match = (/access_token=([^&+]+)/).exec(@browser.hash())
      @browser.save('access_token', match[1])
      @browser.hash('')

    observer = new MutationObserver => @onLocationChange()
    observer.observe $('#js-repo-pjax-container')[0], childList: true
    @onLocationChange()

  onLocationChange: ->
    if @browser.load('block_mutation') == 'true'
      @browser.save('block_mutation', '')
      return

    @api = new API(@browser, @repo, @browser.load('access_token'))
    @render()

    chunks = @browser.path().split("/")
    @repo = "#{chunks[1]}/#{chunks[2]}"

    if @api.authorized()
      @repository = new Repository(@browser, @api, @repo)
      @repository.attributes().then (repo) =>
        @render(repo)

        if @browser.hash() == 'pending'
          @browser.save('block_mutation', true)
          @renderCommits("Pending", repo.pending)
        else if @browser.hash() == 'rejected'
          @browser.save('block_mutation', true)
          @renderCommits("Rejected", repo.rejected)
        else if chunks[3] == 'commit'
          @repository.commit(chunks[4])
            .then(
              (commit) => @renderMenu(commit)
              => @notification("There is no such commit in GHCR database")
            )
        else if chunks[3] == 'commits'
          @commitsPage()

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

    if repo?
      if !repo.connected
        if repo.permissions.admin
          $btn = Template.mini_button('Connect').click (e) =>
            e.preventDefault()
            $btn.prop('disabled', true)

            @api.connect(@repo).then =>
              @notification 'Successfully connected to Github Code Review!
                            New commits will be added to review queue.'

          @notification($('<div> this repository to Github Code Review</div>').prepend($btn))
        else if repo.permissions.push
          @notification('Please ask an admin of this repository to connect Github Code Review.')
      else
        @initNav(repo.pending, repo.rejected)
    else
      @initNav()

  initNav: (pending = [], rejected = []) ->
    $cont = $('.repo-nav-contents')
    $('#ghcr-nav').remove()
    $ul = Template.menu.nav()

    # Pending
    $li = Template.menu.li('Pending')
    $a = Template.menu.a(pending.length, 'pending', '#69B633').click (e) =>
      if @api.authorized()
        @browser.save('block_mutation', true)
        @browser.setLocation("/#{@repo}/commits#pending")
        @renderCommits('Pending', pending)
      else
        @api.authorize()
      e.preventDefault()
      e.stopPropagation()
    $li.append($a)
    $ul.append($li)

    # rejected
    $li = Template.menu.li('Rejected')
    $a = Template.menu.a(rejected.length, 'rejected', '#B66933').click (e) =>
      if @api.authorized()
        @browser.setLocation("/#{@repo}/commits#rejected")
        @browser.save('block_mutation', true)
        @renderCommits('Rejected', rejected)
      else
        @api.authorize()
      e.preventDefault()
      e.stopPropagation()
    $li.append($a)
    $ul.append($li)

    $cont.prepend($ul)

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

  commitsPage: ->
    ids = ($(e).data("clipboard-text") for e in $("li.commit .commit-links .js-zeroclipboard"))
    @api.commits(@repo, {sha: ids.join(',')}).then (commits) =>
      for commit in commits
        $item = $("li.commit .commit-links .js-zeroclipboard[data-clipboard-text=#{commit.id}]").parents("li")
        commit.status ||= "pending"
        $item.addClass("ghcr__commit ghcr__commit--#{commit.status}")

  nextPending: ->
    @api.commits(@repo, author: "!#{@username}", status: 'pending').then (commits) =>
      if commits.length > 0
        currentId = window.location.pathname.split('/').reverse()[0]
        nextCommit = commits[0]
        commitSize = commits.length
        for index in [0..(commitSize-1)]
          if commits[index].id == currentId
            nextCommit = commits[index+1] if index + 1 < commitSize
            break
        window.location = "/#{@repo}/commit/#{nextCommit.id}"
      else
        window.location = "/#{@repo}"

  generateBtn: (commit, btn) ->
    Template.mini_button(btn.label, '.ghcr__status-bar__button').click () =>
      if btn.status == 'next'
        @nextPending()
      else
        commit.status = btn.status
        commit.reviewer = @username
        @api.save(@repo, commit.id, commit).then (data) =>
          if $('#ghcr-auto-next').prop('checked')
            @nextPending()
          else
            @renderMenu(data)

  renderMenu: (commit = {}) ->
    console.log('renderMenu')

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

    if commit.author.username != @username
      if commit.status == 'pending'
        $box.append @generateBtn(commit, acceptBtn)
        $box.append @generateBtn(commit, rejectBtn)
      else
        $box.append @generateBtn(commit, oppBtns[commit.status])
    $box.append @generateBtn(commit, nextPendingBtn)

    $checkbox = $box.find('#ghcr-auto-next')
    $checkbox.prop('checked', @browser.load('next_pending') == 'true')
    $checkbox.click (e) =>
      @browser.save('next_pending', $checkbox.prop('checked'))
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
