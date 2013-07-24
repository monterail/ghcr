class Repository
  RSVP.EventTarget.mixin(@prototype)

  constructor: (@api, @name, @data) ->
  update: ->
    @api.init(@name).then (data) =>
      Storage.set(@name, data)
      @data = data

  cached_attributes: -> Storage.get(@name)

  attributes: ->
    if @data
      new RSVP.Promise (resolve) => resolve(@data)
    else
      if Storage
        @cached_attributes().then (data) =>
          if data?
            @data = data
            @update().then (data) =>
              @data = data
              @render(data)
            @data
          else
            @update().then (data) => @data = data
      else
        @update().then (data) => @data = data

  commit: (sha) ->
    @attributes().then (data) =>
      commit = data.pending.concat(data.rejected)
        .filter((commit) -> commit.id == sha)[0]

      if commit then commit else @api.commit(@name, sha)
