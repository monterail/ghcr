Request =
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
