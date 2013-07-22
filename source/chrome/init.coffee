new class ChromeGHCR extends GHCR
  constructor: ->
    $.extend(@browser, @extendBrowser)
    super

  extendBrowser:
    get: (url, data, access_token) ->
      new RSVP.Promise (resolve, reject) ->
        $.ajax
          method: "GET", url: url, data: data,
          success: resolve, error: reject,
          headers: { "Authorization": "Bearer #{access_token}" }

    put: (url, data, access_token) ->
      new RSVP.Promise (resolve, reject) ->
        $.ajax
          method: "PUT", url: url, data: data,
          success: resolve, error: reject,
          headers: { "Authorization": "Bearer #{access_token}" }

    post: (url, data, access_token) ->
      new RSVP.Promise (resolve, reject) ->
        $.ajax
          method: "POST", url: url, data: data,
          success: resolve, error: reject,
          headers: { "Authorization": "Bearer #{access_token}" }

    storage:
      get: (key) ->
        new RSVP.Promise (resolve) ->
          chrome.storage.local.get [key], (values) ->
            resolve(values[key])

      set: (key, value) ->
        toSave = {}
        toSave[key] = value
        new RSVP.Promise (resolve) ->
          chrome.storage.local.set(toSave, resolve)
