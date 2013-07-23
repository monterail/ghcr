class Browser
  redirect: (url) ->
    document.location = url

  href: -> document.location.href

  path: -> document.location.pathname

  hash: (value) ->
    if value == ""
      loc = window.location
      if "pushState" of history
        history.pushState("", document.title, loc.pathname + loc.search)
    else if value?
      document.location.hash = value
    else
      document.location.hash.substring(1)

  save: (key, value) ->
    $.cookie('ghcr_' + key, value, path: '/')

  load: (key) ->
    $.cookie('ghcr_' + key)
