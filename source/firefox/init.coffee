new class FirefoxGHCR extends GHCR
  browser:

    sendRequest: (type, url, data, cb) ->
      callMe = Math.random().toString(36).substring(7)
      self.port.on callMe, ->
        cb.apply(null, arguments)
      self.port.emit "request:#{type}", url, decodeURIComponent($.param(data)), callMe

    redirect: (url) ->
      document.location = url

    get: (url, data, access_token) ->
      new RSVP.Promise (resolve, reject) =>
        @sendRequest 'get', url, $.extend({access_token}, data), resolve

    put: (url, data, access_token) ->
      new RSVP.Promise (resolve, reject) =>
        @sendRequest 'put', url, $.extend({access_token}, data), resolve

    post: (url, data, access_token) ->
      new RSVP.Promise (resolve, reject) =>
        @sendRequest 'post', url, $.extend({access_token}, data), resolve

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
