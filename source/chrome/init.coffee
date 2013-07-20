Promise = require('promise')

new class ChromeGHCR extends GHCR

  browser:

    redirect: (url) ->
      document.location = url

    get: (url, data, access_token) ->
      new Promise (resolve, reject) ->
        $.ajax
          method: "GET", url: url, data: data,
          success: resolve, error: reject,
          headers: { "Authorization": "Bearer #{access_token}" }

    put: (url, data, access_token) ->
      new Promise (resolve, reject) ->
        $.ajax
          method: "PUT", url: url, data: data,
          success: resolve, error: reject,
          headers: { "Authorization": "Bearer #{access_token}" }

    href: -> document.location.href

    path: -> document.location.pathname

    hash: (value) ->
      if value == ""
        loc = window.location
        if "pushState" of history
          history.pushState("", document.title, loc.pathname + loc.search)
      else if value?
        document.locatino.hash = value
      else
        document.location.hash.substring(1)

    save: (key, value) ->
      $.cookie(key, value, path: '/')

    load: (key) ->
      $.cookie(key)
