# The main module of the Add-on.
Widget  = require("widget").Widget
PageMod = require("sdk/page-mod").PageMod
Request = require("sdk/request").Request
self    = require("sdk/self")
tabs    = require("sdk/tabs")

exports.main = ->
  new Widget
    id: "ghcr",
    label: "GitHub Code Review",
    contentURL: "http://www.mozilla.org/favicon.ico",

  new PageMod
    include: "https://github.com/*"
    contentScriptFile: [self.data.url("ghcr.js")]
    contentStyleFile: [self.data.url("ghcr.css")]
    onAttach: (worker) ->
      createRequest = (url, data, callMe) ->
        Request(
          url: url
          content: data
          onComplete: (res) ->
            worker.port.emit callMe, res.json || {}
        )

      worker.port.on "request:get", (url, data, callMe) ->
        createRequest(url, data, callMe).get()

      worker.port.on "request:post", (url, data, callMe) ->
        createRequest(url, data, callMe).post()

      worker.port.on "request:put", (url, data, callMe) ->
        createRequest(url, data, callMe).put()
