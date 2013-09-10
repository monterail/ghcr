Template =
  notification: ->
    $("<div id='ghcr-notification' class='flash-messages container'><div class='flash flash-notice'><span class='octicon octicon-remove-close close'></span> </div></div>")

  mini_button: (text, classes = "") ->
    $("<button class='minibutton #{classes}'>#{text}</button>")

  menu:
    nav: ->
      $('<ul id="ghcr-nav" class="repo-menu"/>')
    li: (title) ->
      $("<li class='tooltipped leftwards' original-title='#{title}' />")
    a: (icon, text, color) ->
      $("<a href='#' class=''><span class='octicon' style='background-color: #{color}; color: white; border-radius: 3px; padding: 2px 0; font-size: 14px'>#{icon}</span> <span class='full-word'>#{text}</span></a>")


  admin:
    box: ->
      $('<div id="ghcr_admin_box" class="boxed-group flush"><h3>GHCR</h3><div id="ghcr_admin_inner_box" class="boxed-group-inner"></div></div>')
    connect: ->
      $('<div class="addon"> this repository to Github Code Review</div>')
    token: (token) ->
      $("<div class='addon'>Repository access token: <input value='#{token}' readonly></div>")

  commit:
    _info:
      status: (status, username, created_at) -> "Commit <b>#{status}</b> by <a href='https://github.com/#{username}'>#{username}<a/> at #{strftime('%R, %d %b %Y', new Date(created_at))}"
      accepted: (username, created_at) -> @status('accepted', username, created_at)
      rejected: (username, created_at) -> @status('rejected', username, created_at)
      pending: -> "Code pending review"
    box: (status, username, created_at) ->
      $("<div id='ghcr-box' class='ghcr__status-bar ghcr__status-bar--#{status}'><span>#{@_info[status](username, created_at)}</span></div>")


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
      <li class="commit commit-group-item js-navigation-item js-details-container">
        <img class="gravatar" height="36" src="http://github.com/#{avatarUsername}.png" width="36">
        <p class="commit-title  js-pjax-commit-title">
          <a href="#{diffUrl}" class="message">#{message}</a>
        </p>
        <div class="commit-meta">
          <div class="commit-links">
            <span class="js-zeroclipboard zeroclipboard-button" data-clipboard-text="#{id}" data-copied-hint="copied!" title="Copy SHA">
              <span class="octicon octicon-clippy"></span>
            </span>

            <a href="#{diffUrl}" class="gobutton ">
              <span class="sha">#{id.substring(0,10)}
                <span class="octicon octicon-arrow-small-right"></span>
              </span>
            </a>

            <a href="#{treeUrl}" class="browse-button" title="Browse the code at this point in the history" rel="nofollow">
              Browse code <span class="octicon octicon-arrow-right"></span>
            </a>
          </div>

          <div class="authorship">
            <span class="author-name">#{authorNameHtml}</span>
            authored <time class="js-relative-date" datetime="#{timestamp}" title="#{timestamp}"></time>
          </div>
        </div>
      </li>
      """)
