Request =
  sendRequest: (type, url, data, resolve, reject) ->
    request = new EmitCallback("request:#{type}")
    request.apply(url, decodeURIComponent($.param(data)))
    request.emit(resolve, reject)

  promiseRequest: (type, url, data, access_token) ->
    new RSVP.Promise (resolve, reject) ->
      Request.sendRequest type, url, $.extend({access_token}, data), resolve, reject

  get:  (url, data, access_token) ->
    Request.promiseRequest('get', url, data, access_token)

  put:  (url, data, access_token) ->
    Request.promiseRequest('put', url, data, access_token)

  post: (url, data, access_token) ->
    Request.promiseRequest('put', url, data, access_token)
