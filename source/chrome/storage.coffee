Storage =
  get: (key) ->
    new RSVP.Promise (resolve) ->
      chrome.storage.local.get [key], (values) -> resolve(values[key])

  mget: (array) ->
    new RSVP.Promise (resolve) ->
      chrome.storage.local.get array, (values) -> resolve(values)

  set: (key, value) ->
    toSave = {}
    toSave[key] = value
    new RSVP.Promise (resolve) ->
      chrome.storage.local.set toSave, resolve(value)

  mset: (object) ->
    new RSVP.Promise (resolve) ->
      chrome.storage.local.set object, (values) -> resolve(object)
