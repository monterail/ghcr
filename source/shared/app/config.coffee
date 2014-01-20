Config = class
  RSVP.EventTarget.mixin(@prototype)

  init: (@data = {})->
    if match = (/access_token=([^&+]+)/).exec(Page.hash())
      Storage.set('ghcr_access_token', match[1]).then (value) =>
        Page.hash('')
    Storage.mget(['ghcr_access_token', 'ghcr_url', 'ghcr_hipchat_username']).then (results) =>
      @trigger('dataChanged', results)

  setData: (obj) =>
    Storage.mset(obj).then (results) =>
      @trigger('dataChanged', results)
