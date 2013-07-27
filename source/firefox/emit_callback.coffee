class EmitCallback
  constructor: (@message) ->
    @_resolveID = @_genID(7)
    @_rejectID  = @_genID(8)

  apply: ->
    (@arguments = Array.prototype.slice.call(arguments)) && this

  emit: (@resolve, @reject) ->
    @_defineCallbacks()
    self.port.on @_rejectID, @_reject
    self.port.on @_resolveID, @_resolve
    self.port.emit.apply(self.port, @_arguments())

  _defineCallbacks: ->
    [_rejectID, _resolveID, reject, resolve] = [@_rejectID, @_resolveID, @reject, @resolve]
    _resolve = ->
      self.port.removeListener _rejectID, _reject
      resolve.apply(null, arguments)
    _reject = ->
      self.port.removeListener _resolveID, _resolve
      reject.apply(null, arguments)
    [@_reject, @_resolve] = [_reject, _resolve]

  _genID: (length) ->
    Math.random().toString(36).substring(length)

  _arguments: ->
    [@message].concat(@arguments).concat(@_resolveID, @_rejectID)
