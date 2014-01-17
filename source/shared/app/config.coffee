Config = class
  RSVP.EventTarget.mixin(@prototype)

  init: (@data = {})->
    if match = (/access_token=([^&+]+)/).exec(Page.hash())
      console.log 'match token'
      Storage.set('ghcr_access_token', match[1]).then (value) =>
        Page.hash('')

    Storage.mget(['ghcr_access_token', 'ghcr_url', 'ghcr_hipchat_username']).then (results) =>
      @data = results
      @trigger('dataChanged')

  setData: (obj) =>
    Storage.mset(obj).then (results) =>
      @data = results
      @trigger('dataChanged')
