new class FirefoxGHCR extends GHCR
  constructor: ->
    $.extend(@browser, @extendBrowser)
    super

  extendBrowser:
    sendRequest: (type, url, data, cb) ->
      callMe = Math.random().toString(36).substring(7)
      self.port.on callMe, cb
      self.port.emit "request:#{type}", url, decodeURIComponent($.param(data)), callMe

    get: (url, data, access_token) ->
      new RSVP.Promise (resolve, reject) =>
        @sendRequest 'get', url, $.extend({access_token}, data), resolve

    put: (url, data, access_token) ->
      new RSVP.Promise (resolve, reject) =>
        @sendRequest 'put', url, $.extend({access_token}, data), resolve

    post: (url, data, access_token) ->
      new RSVP.Promise (resolve, reject) =>
        @sendRequest 'post', url, $.extend({access_token}, data), resolve
