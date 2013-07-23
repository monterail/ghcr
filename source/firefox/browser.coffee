class FirefoxBrowser extends Browser
  sendRequest: (type, url, data, resolve, reject) ->
    callMeReject  = Math.random().toString(36).substring(8)
    callMeResolve = Math.random().toString(36).substring(7)
    resolveplus = ->
      self.port.removeListener callMeReject, rejectplus
      resolve.apply(null, arguments)
    rejectplus = ->
      self.port.removeListener callMeResolve, resolveplus
      reject.apply(null, arguments)
    self.port.on callMeReject, rejectplus
    self.port.on callMeResolve, resolveplus
    self.port.emit "request:#{type}", url, decodeURIComponent($.param(data)), callMeResolve, callMeReject

  get: (url, data, access_token) ->
    new RSVP.Promise (resolve, reject) =>
      @sendRequest 'get', url, $.extend({access_token}, data), resolve, reject

  put: (url, data, access_token) ->
    new RSVP.Promise (resolve, reject) =>
      @sendRequest 'put', url, $.extend({access_token}, data), resolve, reject

  post: (url, data, access_token) ->
    new RSVP.Promise (resolve, reject) =>
      @sendRequest 'post', url, $.extend({access_token}, data), resolve, reject
