Template =
  notification: ->
    $("<div id='ghcr-notification' class='flash-messages container'><div class='flash flash-notice'><span class='octicon octicon-remove-close close'></span> </div></div>")

  mini_button: (text, classes = "") ->
    $("<button class='minibutton #{classes}'>#{text}</button>")

  remove_commit: ->
   $("<div class='container'><h2>This commit no longer exists.</h2><button class='button'>Remove from GHCR</button></div>")

  menu:
    nav: ->
      $('<ul id="ghcr-nav" class="sunken-menu-group"/>')
    li: (title) ->
      $("<li class='tooltipped tooltipped-w' aria-label='#{title}' />")
    a: (icon, text, color) ->
      $("<a href='#' class='sunken-menu-item'><span class='octicon' style='background-color: #{color}; color: white; border-radius: 3px; padding: 2px 0; font-size: 14px'>#{icon}</span> <span class='full-word'>#{text}</span></a>")


  admin:
    box: ->
      $('<div id="ghcr_admin_box" class="boxed-group"><h3>GHCR</h3><div id="ghcr_admin_inner_box" class="boxed-group-inner"></div></div>')
    connect: ->
      $('<p> this repository to Github Code Review</p>')
    token: (token) ->
      $("<p>Repository access token: <input value='#{token}' readonly></p>")

  commit:
    _info:
      status: (status, username, created_at) ->
        "Commit <b>#{status}</b> by <a href='https://github.com/#{username}'>#{username}<a/> at #{created_at}"
      'accepted'      : (username, created_at) -> @status('accepted', username, created_at)
      'discuss'       : (username, created_at) -> @status('up for discussion', username, created_at)
      'auto-accepted' : (username, created_at) -> @status('auto-accepted', username, created_at)
      'pending'       : -> "Code pending review"
    box: (status, username, created_at) ->
      _status = try
        @_info[status](username, created_at)
      catch e
        "Unsupported commit status: #{status}"
      $("<div id='ghcr-box' class='ghcr__status-bar ghcr__status-bar--#{status}'><span>#{_status}</span></div>")


  commits:
    header: (repo, title) -> $("""
      <div class="file-navigation">
        <div class="breadcrumb">
        <span class="repo-root js-repo-root"><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/#{repo}" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">#{repo.split('/')[1]}</span></a></span></span><span class="separator"> / </span>#{title}
        </div>
      </div>
      <h3 class="commit-group-heading"></h3>
      """)
    commit: (id, message, timestamp, diffUrl, treeUrl, avatarUsername, authorNameHtml) -> $("""
      <li class="commit commits-list-item table-list-item js-navigation-item js-details-container js-socket-channel js-updatable-content">
        <div class="table-list-cell commit-avatar-cell">
          <div class="authorship">
            <a href="/#{avatarUsername}" data-skip-pjax="true" rel="contributor"><img alt="#{avatarUsername}" class="avatar" height="36" src="http://github.com/#{avatarUsername}.png" width="36"></a>
          </div>
        </div>
        <div class="commit-body table-list-cell">
          <p class="commit-title">
            <a href="#{diffUrl}" class="message">#{message}</a>
          </p>
          <div class="commit-meta">
            <span class="author-name">#{authorNameHtml}</span>
            authored <time datetime="#{timestamp}" is="relative-time" title="#{timestamp}"></time>
          </div>
        </div>
        <div class="commit-links table-list-cell">
          <div class="commit-links-group button-group">
            <button class="js-zeroclipboard button-outline zeroclipboard-button" data-clipboard-text="#{id}" data-copied-hint="Copied!" type="button" aria-label="Copy the full SHA"><span class="octicon octicon-clippy"></span></button>
            <a href="#{diffUrl}" class="sha button-outline">
              #{id.substring(0,10)}
            </a>
          </div>
          <a href="#{treeUrl}" aria-label="Browse the code at this point in the history" class="button-outline tooltipped tooltipped-s" rel="nofollow"><span class="octicon octicon-code"></span></a>
        </div>
      </li>
      """)
