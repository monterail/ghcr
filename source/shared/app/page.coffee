Page =
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

  setLocation: (path, title=document.title, state={}) ->
    history.pushState(state, title, path)

  refresh: ->
    location.reload(true)
