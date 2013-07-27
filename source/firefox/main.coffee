# The main module of the Add-on.
PageMod = require("sdk/page-mod").PageMod
Request = require("sdk/request").Request
self    = require("sdk/self")
ss      = require("sdk/simple-storage")

exports.main = ->
  new PageMod
    include: "https://github.com/*"
    contentScriptFile: [self.data.url("ghcr.js")]
    contentStyleFile: [self.data.url("ghcr.css")]
    onAttach: (worker) ->
      # Cross domain requests
      createRequest = (url, data, resolve, reject) ->
        Request(
          url: url
          content: data
          headers:
            'X-Requested-With': 'XMLHttpRequest'
          onComplete: (res) ->
            watToDziab = if res.status < 400 then resolve else reject
            worker.port.emit watToDziab, res.json || {}
        )

      worker.port.on "request:get", (url, data, resolve, reject) ->
        createRequest(url, data, resolve, reject).get()

      worker.port.on "request:post", (url, data, resolve, reject) ->
        createRequest(url, data, resolve, reject).post()

      worker.port.on "request:put", (url, data, resolve, reject) ->
        createRequest(url, data, resolve, reject).put()

      # Local storage
      worker.port.on "storage:get", (key, resolve) ->
        worker.port.emit resolve, ss.storage[key]

      worker.port.on "storage:set", (key, value, resolve) ->
        ss.storage[key] = value
        worker.port.emit resolve
