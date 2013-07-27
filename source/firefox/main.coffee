# The main module of the Add-on.
Widget  = require("widget").Widget
PageMod = require("sdk/page-mod").PageMod
Request = require("sdk/request").Request
self    = require("sdk/self")
tabs    = require("sdk/tabs")

exports.main = ->
  new PageMod
    include: "https://github.com/*"
    contentScriptFile: [self.data.url("ghcr.js")]
    contentStyleFile: [self.data.url("ghcr.css")]
    onAttach: (worker) ->
      createRequest = (url, data, resolve, reject) ->
        Request(
          url: url
          content: data
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
