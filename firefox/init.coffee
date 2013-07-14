init = ->
  chunks = window.location.pathname.split("/")
  repo = "#{chunks[1]}/#{chunks[2]}"

  GHCR.init repo, ->
    if window.location.hash == "#ghcr-pending"
      GHCR.pending()
    else if window.location.hash == "#ghcr-rejected"
      GHCR.rejected()
    else
      switch chunks[3]
        when "commits" # Commit History page
          GHCR.commitsPage()
        when "commit" # Commit details page
          GHCR.commitPage(chunks[4])

self.port.on "init", init

XHR = unsafeWindow.XMLHttpRequest
legacySend = XMLHttpRequest.prototype.send

XHR.prototype.send = ->
  legacyORSC = @onreadystatechange
  @onreadystatechange = ->
    if @readyState == 4 && @getResponseHeader("X-PJAX-VERSION")?
      setTimeout(init, 100)
    legacyORSC.apply(this, arguments)
  legacySend.apply(this, arguments)
