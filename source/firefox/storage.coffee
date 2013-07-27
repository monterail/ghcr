Storage =
  get: (key) ->
    new RSVP.Promise (resolve) ->
      new EmitCallback("storage:get").apply(key).emit(resolve)

  set: (key, value) ->
    new RSVP.Promise (resolve) ->
      new EmitCallback("storage:set").apply(key, value).emit(resolve)
