class Repository
  RSVP.EventTarget.mixin(@prototype)

  constructor: (@name, @api) ->
  update: ->
    @api.init(@name).then (data) =>
      @data = data

  attributes: ->
    @update().then (data) => @data = data

  commit: (sha) ->
    @attributes().then (data) =>
      commit = data.pending.concat(data.discuss)
        .filter((commit) -> commit.id == sha)[0]

      if commit then commit else @api.commit(@name, sha)
