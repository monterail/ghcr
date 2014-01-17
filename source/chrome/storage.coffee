Storage =
  get: (key) ->
    new RSVP.Promise (resolve) ->
      chrome.storage.local.get [key], (values) ->
        resolve(values[key])

  set: (key, value) ->
    toSave = {}
    toSave[key] = value
    new RSVP.Promise (resolve) ->
      chrome.storage.local.set(toSave, resolve(value))
