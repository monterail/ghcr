Browser =
  redirect: (url) ->
    document.location = url

  href: -> document.location.href

  path: -> document.location.pathname

  hash: (value) ->
    if value == ""
      @setLocation(@path() + window.location.search)
    else if value?
      document.location.hash = value
    else
      document.location.hash.substring(1)

  save: (key, value) ->
    $.cookie('ghcr_' + key, value, path: '/')

  load: (key) ->
    $.cookie('ghcr_' + key)

  setLocation: (path, title=document.title, state={}) ->
    history.pushState(state, title, path)
